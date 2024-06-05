class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :bulk_discounts, through: :item

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def find_discount
    # This is definitely a similar implementation to the Invoice#total_discount method but I needed a way to get the applied discount even if there were multiple eligible discounts for an invoice item
    self.bulk_discounts
        .where("? >= bulk_discounts.quantity_threshold", self.quantity)
        .select("bulk_discounts.*, MAX((#{self.unit_price} * #{self.quantity}) * (bulk_discounts.percentage / 100.0)) as total_discount")
        .group("bulk_discounts.id")
        .order(total_discount: :desc)
        .first

    # SELECT bulk_discount.*, MAX((<Invoice Item Unit Price> * <Invoice Item Quantity>) * (bulk_discounts.percentage / 100.0)) as total_discount
    # FROM "bulk_discounts"
    #   INNER JOIN "merchants" ON "bulk_discounts"."merchant_id" = "merchants"."id"
    #   INNER JOIN "items" ON "merchants"."id" = "items"."merchant_id"
    # WHERE "items"."id" = <Invoice Item Item ID>
    #   AND (<Invoice Item Quantity> >= bulk_discounts.quantity_threshold)
    # GROUP BY "bulk_discounts"."id"
  end
end
