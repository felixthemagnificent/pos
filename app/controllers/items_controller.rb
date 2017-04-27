class ItemsController < ApplicationController
  before_action :role_required
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_item_from_barcode, only: [:process_cheque, :search]

  # GET /items
  # GET /items.json
  def index
    @items = Item.resolve(current_user)
  end

  # GET /items/1
  # GET /items/1.json
  def show
    render layout: false
  end

  def addbarcode
    item = Item.find(params[:item_id])
    barcode = params[:barcode]
    Barcode.create!(item: item, code: barcode)
    render json: nil, status: :ok
  end

  def list
    items = Item.all
    grid_data = []
    types = {
      name: 'string'
    }

    items, total = KendoFilter.filter_grid(params, items, types)
    items.each do |item|
      grid_data.push({
        name: item.name,
        item_id: item.id
      })
    end

    render json: {data: grid_data, total: total}
  end

  def search
    if @item
      render json: @item.slice(:name, :id)
    else
      render json: nil, status: :unprocessable_entity
    end
  end

  def process_cheque
    delete = params.key? 'delete'
    if @item
      if delete
        @barcode.transaction do
          batch = Batch.for_user(current_user).where(barcode: @barcode).first
          if batch.locked_amount > 0
            batch.count += 1
            batch.locked_amount -= 1
            batch.save!
            count = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).try(:first).try(:count)
            if count && count > 1
              item = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              item.count -= 1
              item.save!
            elsif count && count == 1
              item = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              Receipt.for_user(current_user).last_opened.positions.delete item
            end
          end
        end
        render json: nil, status: :ok
      else
        batch = Batch.for_user(current_user).where(barcode: @barcode).first rescue nil
        if batch.count > 0
          @barcode.transaction do
            batch.count -= 1
            batch.locked_amount += 1
            batch.save!
            if Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).try(:first)
              position = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              position.count += 1
              position.save!
            else
              Receipt.for_user(current_user).last_opened.positions << Position.create(batch: batch, item: @item, count: 1, price: batch.price)
            end
          end
          render json: @item.slice(:name).merge({price: batch.price, code: @barcode.code})
        else
          render json: { error: 'insufficient_amount' }, status: :unprocessable_entity
        end
      end
    else
      render json: nil, status: :unprocessable_entity
    end

  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)
    @item.user = current_user
    @item.company = current_user.company
    if @item.save
      render json: @item, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    if @item.update(item_params)
      render json: @item, status: :ok
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    render json: nil
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_item_from_barcode
      @barcode = Barcode.find_by_code(params[:barcode])
      @item = @barcode.try(:item)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.permit(:name)
    end
end
