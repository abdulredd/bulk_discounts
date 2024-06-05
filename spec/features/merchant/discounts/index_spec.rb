require "rails_helper"

RSpec.describe "Merchant Discounts Index Page", type: :feature do
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

    @discount_1 = BulkDiscount.create!(percentage: 20, quantity_threshold: 10, merchant: @merchant1)
    @discount_2 = BulkDiscount.create!(percentage: 30, quantity_threshold: 15, merchant: @merchant1)

    visit merchant_discounts_path(@merchant1)
  end

  describe "As a merchant" do
    describe "When I visit my merchant bulk discounts index page" do


      describe "1: Merchant Bulk Discounts Index (Part 2)" do
        it "I see all of my bulk discounts including their percentage discount and quantity thresholds" do
          within "#all-discounts" do
            expect(page).to have_content("Take #{@discount_1.percentage}% off when you purchase #{@discount_1.quantity_threshold} or more.")
            expect(page).to have_content("Take #{@discount_2.percentage}% off when you purchase #{@discount_2.quantity_threshold} or more.")
          end
        end

        it "And each bulk discount listed includes a link to its show page" do
          # Loop through each paragraph
          # https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FNode%2FFinders:all
          all(".discount p") do |paragraph|
            within paragraph do
              expect(page).to have_link "Show Discount"
            end
          end
        end
      end

      describe "2: Merchant Bulk Discount Create (Part 1)" do
        it "I see a link to create a new discount" do
          expect(page).to have_link "Create New Discount"
        end

        it "When I click this link, then I am taken to a new page where I see a form to add a new bulk discount" do
          click_link "Create New Discount"

          expect(current_path).to eq(new_merchant_discount_path(@merchant1))
        end
      end

      describe "3: Merchant Bulk Discount Delete" do
        it "Then next to each bulk discount I see a link to delete it" do
          # Loop through each paragraph
          # https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FNode%2FFinders:all
          all(".discount p") do |paragraph|
            within paragraph do
              expect(page).to have_link "Delete Discount"
            end
          end
        end

        it "When I click this link, then I am redirected back to the bulk discounts index page" do
          click_link "Delete Discount", match: :first

          expect(current_path).to eq(merchant_discounts_path(@merchant1))
        end

        it "And I no longer see the discount listed" do
          click_link "Delete Discount", match: :first

          within "#all-discounts" do
            expect(page).to_not have_content("Take 20% off when you purchase 10 or more. Show Discount")
            expect(page).to have_content("Take 30% off when you purchase 15 or more. Show Discount")
          end
        end
      end
    end
  end
end
