class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: [:cancelled, :in_progress, :completed]

  def merchant_items(merchant)
    self.invoice_items.joins(:item).where(items: { merchant_id: merchant.id })
  end

  def merchant_total_revenue(merchant)
    # This is the correct query because now we are only looking at the revenue of items from this merchant ONLY and not from all merchants who happen to be on the same invoice.
    # I needed to join Items to gain access to the `merchant_id` column.
    self.invoice_items
        .joins(:item)
        .where(items: { merchant_id: merchant.id })
        .sum("invoice_items.unit_price * quantity")

    # Previous implementation from base repo given to students which gets the total revenue from all items, even the ones that are not owned by this merchant.
    # invoice_items.sum("unit_price * quantity")
  end

  def total_revenue
    # This `total_revenue` method is used in the admin views to get the total for an invoice that includes all the merchants and not just for a single merchant
    invoice_items.sum("unit_price * quantity")
  end

  def merchant_discount_amount(merchant)
    # Need to determine all the discounts available for this invoice

    # ====================== VERSION 1 ======================

    # SELECT invoice_items.id, MAX((quantity * invoice_items.unit_price) * (percentage / 100.0)) AS total_discount
    # FROM invoice_items
    #   JOIN items ON items.id = invoice_items.item_id
    #   JOIN merchants ON merchants.id = items.merchant_id
    #   JOIN bulk_discounts ON bulk_discounts.merchant_id = merchants.id
    # WHERE invoice_items.invoice_id = <Invoice ID>
    #   AND quantity >= quantity_threshold
    # GROUP BY invoice_items.id

    invoice_items.joins(:bulk_discounts)
                 .select("invoice_items.id, MAX((invoice_items.unit_price * invoice_items.quantity) * (bulk_discounts.percentage / 100.0)) as total_discount")
                 .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
                 .where(items: { merchant_id: merchant.id })
                 .group("invoice_items.id")
                 .order(total_discount: :desc)
                 .sum(&:total_discount)

    # ====================== VERSION 2 ======================

    # By doing this sub-query (SELECT from SELECT) I no longer have to do .sum(&:total_discount), I will get the SUM of all the total discount columns by passing it into another query that will just be used to sum the 2 columns.
    # This `from_sql` will contain just the total_discount column with each row representing an invoice item and the discount applied to that item, some columns may be null if no discount was applied
    from_sql = invoice_items.joins(:bulk_discounts)
                            .select("MAX((invoice_items.unit_price * invoice_items.quantity) * (bulk_discounts.percentage / 100.0)) as total_discount")
                            .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
                            .where(items: { merchant_id: merchant.id })
                            .group("invoice_items.id")
                            .order(total_discount: :desc).to_sql # Notice that this is being converted to pure SQL to be used below

    # COALESCE() will evaluate the arguments in the provided order and return the first non-null value
    # I am using it here because there is a possibility of null if the invoice item doesn't have any discounts applied
    # Note: I am using Invoice.select here but it doesn't really matter since none of the invoice columns actually get "selected"
    Invoice.select("COALESCE(SUM(total_discount), 0) AS discount")
           .from("(#{from_sql}) AS sub_query_must_be_aliased")[0].discount # I have to do [0].discount because even though I am getting back a single row, it is still coming back as an array. #discount is the name of the alias column in the #select. I could also use #first

    # SELECT COALESCE(SUM(total_discount), 0) AS discount
    # FROM (SELECT MAX((invoice_items.unit_price * invoice_items.quantity) * (bulk_discounts.percentage / 100.0)) as total_discount
    #       FROM "invoice_items"
    #         INNER JOIN "items" ON "items"."id" = "invoice_items"."item_id"
    #         INNER JOIN "merchants" ON "merchants"."id" = "items"."merchant_id"
    #         INNER JOIN "bulk_discounts" ON "bulk_discounts"."merchant_id" = "merchants"."id"
    #       WHERE "invoice_items"."invoice_id" = <Invoice ID>
    #         AND (invoice_items.quantity >= bulk_discounts.quantity_threshold)
    #       GROUP BY "invoice_items"."id"
    #       ORDER BY "total_discount" DESC) AS sub_query_must_be_aliased
  end

  def discount_amount
    from_sql = invoice_items.joins(:bulk_discounts)
                            .select("MAX((invoice_items.unit_price * invoice_items.quantity) * (bulk_discounts.percentage / 100.0)) as total_discount")
                            .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
                            .group("invoice_items.id")
                            .order(total_discount: :desc).to_sql

    Invoice.select("COALESCE(SUM(total_discount), 0) AS discount")
           .from("(#{from_sql}) AS sub_query_must_be_aliased")[0].discount
  end
end
