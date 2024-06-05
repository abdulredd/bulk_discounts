class Merchant::DiscountsController < ApplicationController
  before_action :set_merchant, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  def index
  end

  def show
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @discount = BulkDiscount.new
  end

  def create
    @discount = @merchant.bulk_discounts.new(bulk_discount_params)

    if @discount.save
      redirect_to merchant_discounts_path(@merchant)
    else
      flash[:alert] = "Something went wrong!"
      render :new
    end
  end

  def edit
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    @discount = BulkDiscount.find(params[:id])

    if @discount.update(bulk_discount_params)
      redirect_to merchant_discount_path(@merchant, @discount)
    else
      flash[:alert] = "Something went wrong!"
      render :edit
    end
  end

  def destroy
    discount = BulkDiscount.find(params[:id])
    discount&.destroy

    redirect_to merchant_discounts_path(@merchant)
  end

  private

  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def bulk_discount_params
    # params.require(:bulk_discount).permit(:percentage, :quantity_threshold, :item_id)
    params.permit(:percentage, :quantity_threshold, :item_id)
  end
end
