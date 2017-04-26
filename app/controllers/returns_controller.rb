class ReturnsController < ApplicationController
  def index
  end

  def create
    ReturnReceipt.transaction do
      return_receipt = ReturnReceipt.create!(user: current_user, receipt: Receipt.find(params[:receipt_id]))
      params[:items].each do |_,item|
        position = Position.find(item[:position_id])
        amount = item[:amount].to_i
        ReturnReceiptPosition.create!(return_receipt: return_receipt, position: position, amount: amount)
        position.batch.count += amount
        position.batch.save!
      end
    end
    render json: { cheque: return_receipt.getCheque }
  end
end
