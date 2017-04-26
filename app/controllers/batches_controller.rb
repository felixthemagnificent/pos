class BatchesController < ApplicationController
  before_action :role_required
  before_action :set_batch, only: [:journal, :writeoff, :update, :destroy]

  # GET /batches
  # GET /batches.json
  def index
    respond_to do |format|
      format.html
      format.json do
        types = { name: "string" }
        custom_field = { name: lambda do |name|
          "(`items`.`name` like '%#{name}'%)"
        end
        }
        items = Batch.for_user(current_user).joins(:item)
        items, total = KendoFilter.filter_grid(params,items, types)
        items = items.map do |e|
          {
            id: e.id,
            name: e.item.name,
            item_id: e.item.id,
            batch_count: e.count,
            last_added: e.created_at,
            price: e.price,
            amount: e.count
          } if e.item
        end
        render json: {data:items, total: total }
      end
    end
  end
  def writeoff
    amount = params[:amount].to_i
    reason = params[:reason]
    @batch.transaction do
      raise ActiveRecord::Rollback if amount > @batch.count
      WriteOff.create!(batch: @batch, item: @batch.item, amount: amount, reason: reason)
      @batch.count -= amount
      @batch.save
    end
    render json: nil
  end

  def journal
    respond_to do |format|
      format.html { render :show, layout: false }
      format.json do
        grid_data = []
        receipts = Receipt.joins(:positions).where(positions: {batch: @batch})
        writeoffs = WriteOff.where(batch: @batch)
        receipts.each do |receipt|
          grid_data << {
            id: @batch_id,
            type: 'Чек',
            amount: Position.where(batch: @batch).try(:first).try(:count),
            date: receipt.created_at
          }
        end
        writeoffs.each do |writeoff|
          grid_data << {
            id: @batch_id,
            type: 'Списание',
            amount: writeoff.amount,
            category: WriteOff.category_names[writeoff.reason.to_sym],
            date: writeoff.created_at,
          }
        end

        ReturnReceiptPosition.joins(:position).where(positions: {batch: @batch}).each do |rrp|
          grid_data << {
            id: @batch_id,
            type: 'Возврат',
            amount: rrp.amount,
            date: rrp.created_at,
          }
        end

        grid_data.sort_by! { |date| date[:date] }
        render json: grid_data
      end
    end
  end

  # GET /batches/1
  # GET /batches/1.json
  def show
    respond_to do |format|
      format.html { render layout: false }
      format.json do
        batches = Batch.where(item_id: params[:id])
        render json: batches
      end
    end
  end

  # POST /batches
  # POST /batches.json
  def create
    @batch = Batch.new
    @batch.item = Item.find(params[:item_id])
    @batch.count = params[:amount].to_i
    @batch.price = params[:price].to_i
    @batch.barcode = Barcode.find_by_code params[:barcode]
    @batch.user = current_user
    respond_to do |format|
      if @batch.save
        format.json { render json: nil, status: :created }
      else
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batches/1
  # PATCH/PUT /batches/1.json
  def update
    @batch.price = params[:price].to_i
    @batch.count = params[:count].to_i
    respond_to do |format|
      if @batch.save
        format.html { redirect_to @batch, notice: 'Batch was successfully updated.' }
        format.json { render json: nil, status: :ok}
      else
        format.html { render :edit }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batches/1
  # DELETE /batches/1.json
  def destroy
    @batch.destroy
    respond_to do |format|
      format.html { redirect_to batches_url, notice: 'Batch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_batch
      @batch = Batch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def batch_params
      params.require(:batch).permit(:item_id, :user_id, :count)
    end
end
