class ReceiptsController < ApplicationController
  before_action :role_required
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def close
    data = {}
    status = :ok
    Receipt.transaction do
      receipt = Receipt.resolve(current_user).last_opened
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
        Receipt.create!(user: current_user, company: current_user.company, status: :opened) unless Receipt.for_user(current_user).last_opened
        data = receipt.getCheque(current_user)
      else
        raise ActiveRecord::Rollback
      end
    end
    render json: {cheque: data}, status: status
  end

  def clear
    data = {}
    status = :ok
    Receipt.transaction do
      receipt = Receipt.for_user(current_user).last_opened
      if receipt.positions.count
      receipt.positions.each do |position|
        batch = position.batch #Batch.for_user(current_user).where(item: position.item).first
        batch.count += batch.locked_amount
        batch.locked_amount = 0
        batch.save!
        position.destroy!
       end
      end
    end
    render json: nil, status: status
  end

  def last_opened
    positions = Receipt.for_user(current_user).last_opened.positions.map do |position|
        {
          ItemName: position.item.name,
          Price: (position.item.have_weight ? (position.batch.price * position.count / 1000) : (position.batch.price)),
          Barcode: position.batch.barcode.code,
          Amount: position.count,
          have_weight: position.item.have_weight
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
            price: e.batch.price,
            supplier_price: e.batch.supplier_price,
            amount: e.count,
            position_id: e.id,
            batch_id: e.batch.id
          }
        }
      end
    end
  end

  # GET /receipts/new
  def new
    Receipt.create!(user: current_user, company: current_user.company, status: :opened) unless Receipt.for_user(current_user).last_opened
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
