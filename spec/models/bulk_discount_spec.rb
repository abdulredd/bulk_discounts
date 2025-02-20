require "rails_helper"

RSpec.describe BulkDiscount, type: :model do
  describe "relationships" do
    it { should belong_to :merchant }
  end

  describe "validations" do
    it { should validate_numericality_of(:percentage).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
    it { should validate_numericality_of(:quantity_threshold).is_greater_than_or_equal_to(0) }
  end
end
