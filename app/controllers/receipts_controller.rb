class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def close
    data = {}
    status = :ok
    Receipt.transaction do
      receipt = Receipt.for_user(current_user).last_opened
      if receipt.positions.count
        receipt.closed!
        receipt.positions.each do |position|
          batch = position.batch #Batch.for_user(current_user).where(item: position.item).first
          batch.locked_amount = 0
          batch.save!
        end
        receipt.paid = params['paid']
        if receipt.paid < receipt.total
          status = :unprocessable_entity
          data = {reason: 'not_enough_paid', value:(receipt.total - receipt.paid) }
          raise ActiveRecord::Rollback
        end

        receipt.save!
        Receipt.create!(user: current_user, status: :opened)
        data = receipt.getCheque
      else
        raise ActiveRecord::Rollback
      end
    end
    render json: {cheque: data}, status: status
  end

  def last_opened
    positions = Receipt.for_user(current_user).last_opened.positions.map do |position|
        {
          ItemName: position.item.name,
          Price: Batch.where(item_id: position.item.id).where.not(count: 0).try(:first).try(:price),
          Barcode: position.batch.barcode.code,
          Amount: position.count
        }
    end
    render json: positions
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    respond_to do |format|
      format.html { render layout: false }
      format.json do
        render json: @receipt.positions.map { |e|
          {
            name: e.item.name,
            price: Batch.for_user(current_user).where(item: e.item).first.price,
            amount: e.count
          }
        }
      end
    end
  end

  # GET /receipts/new
  def new
    Receipt.create!(user: current_user, status: :opened) unless Receipt.for_user(current_user).last_opened
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
