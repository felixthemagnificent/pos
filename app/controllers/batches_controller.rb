class BatchesController < ApplicationController
  before_action :role_required
  before_action :set_batch, only: [:update, :destroy]

  # GET /batches
  # GET /batches.json
  def index
    respond_to do |format|
      format.html
      format.json do
        item_ids = Batch.for_user(current_user).select(:item_id).distinct.map(&:item_id)
        items = Item.where(id: item_ids).map { |e|
          {
            name: e.name,
            item_id: e.id,
            batch_count: Batch.where(item_id: e.id).count,
            last_added: Batch.where(item_id: e.id).try(:last).try(:created_at),
            price: Batch.where(item_id: e.id).where.not(count: 0).try(:first).try(:price),
            amount: Batch.where(item_id: e.id).map(&:count).inject(&:+)
          }
        }
        render json: items
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
