class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def close_receipt
    data = {}
    status = :ok
    Receipt.transaction do
      receipt = Receipt.new
      receipt.user = current_user
      items = params['items']
      items.each_pair do |_,item|
        barcode = item[:Barcode]
        barcode_item = Barcode.for_user(current_user).find_by_code(barcode)
        if barcode_item && barcode.in_stock
          barcode_item.count -= 1
          barcode_item.save!
          receipt.items << barcode_item.item
        elsif barcode_item && barcode_item.count <= 0
          status = :unprocessable_entity
          data = {reason: 'invalid_barcode', value: barcode}
          raise ActiveRecord::Rollback
        else
          status = :unprocessable_entity
          data = {reason: 'invalid_barcode', value: barcode}
          raise ActiveRecord::Rollback
        end
      end
      receipt.paid = params['paid']
      if receipt.paid < receipt.total
        status = :unprocessable_entity
        data = {reason: 'not_enough_paid', value:(receipt.total - receipt.paid) }
        raise ActiveRecord::Rollback
      end
      receipt.save!
      data = receipt.getCheque
    end
    render json: {cheque: data}, status: status
  end

  # GET /receipts
  # GET /receipts.json
  def index
    @receipts = Receipt.where(user: current_user)
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    respond_to do |format|
      format.html { render layout: false }
      format.json do
        render json: @receipt.items.map { |e| { name: e.name, price: e.price} }
      end
    end
  end

  # GET /receipts/new
  def new
  end

  # GET /receipts/1/edit
  def edit
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to @receipt, notice: 'Receipt was successfully created.' }
        format.json { render :show, status: :created, location: @receipt }
      else
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: 'Receipt was successfully updated.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    @receipt.destroy
    respond_to do |format|
      format.html { redirect_to receipts_url, notice: 'Receipt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(:total)
    end

    def item_params
      params.require(:items)
    end
end
