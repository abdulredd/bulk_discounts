require "rails_helper"

RSpec.describe "Merchant Bulk Discounts Edit Page" do
  before :each do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    @customer_2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    @customer_3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    @customer_4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    @customer_5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    @customer_6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @discount_1 = BulkDiscount.create!(percentage: 20.0, quantity_threshold: 10, merchant: @merchant1)
    @discount_2 = BulkDiscount.create!(percentage: 30.0, quantity_threshold: 15, merchant: @merchant1)

    visit edit_merchant_discount_path(@merchant1, @discount_1)
  end

  describe "As a merchant" do
    describe "When I visit my bulk discount edit page" do

      describe "5: Merchant Bulk Discount Edit (Part 2)" do
        context "Happy Path" do
          it "I see that the discounts current attributes are pre-populated in the form" do
            expect(page).to have_field :percentage, with: @discount_1.percentage
            expect(page).to have_field :quantity_threshold, with: @discount_1.quantity_threshold
          end

          it "When I change any/all of the information and click submit, then I am redirected to the bulk discount's show page" do
            fill_in :percentage, with: 10
            fill_in :quantity_threshold, with: 20

            click_button "Save"

            expect(current_path).to eq(merchant_discount_path(@merchant1, @discount_1))
          end

          it "And I see that the discount's attributes have been updated" do
            fill_in :percentage, with: 10
            fill_in :quantity_threshold, with: 20

            click_button "Save"

            expect(page).to have_content("Quantity Threshold: 20 min")
            expect(page).to have_content("Discount Percentage: 10% off")
          end
        end

        context "Sad Path" do
          it "redirects back to the form when I try to update the form with invalid data" do
            fill_in :percentage, with: 1000
            fill_in :quantity_threshold, with: 20

            click_button "Save"

            expect(current_path).to eq(merchant_discount_path(@merchant1, @discount_1))

            expect(page).to have_field :percentage, with: 1000
            expect(page).to have_field :quantity_threshold, with: 20
          end
        end
      end
    end
  end
end
