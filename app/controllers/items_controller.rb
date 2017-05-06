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
      render json: @item.slice(:name, :id, :have_weight)
    else
      render json: nil, status: :unprocessable_entity
    end
  end

  def process_cheque
    delete = params.key? 'delete'
    amount = params['amount'].to_f || 0
    if @item && (delete || amount > 0 || !@item.have_weight)
      if delete
        @barcode.transaction do
          batch = Batch.for_user(current_user).where(barcode: @barcode).first
          if batch.locked_amount > 0
            if @item.have_weight
              batch.count += batch.locked_amount
              batch.locked_amount = 0
            else
              batch.count += 1
              batch.locked_amount -= 1
            end
            batch.save!
            count = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).try(:first).try(:count)
            if count && count > 1 && !@item.have_weight
              position = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              position.count -= 1
              position.save!
            elsif (count && count == 1) || @item.have_weight
              position = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              Receipt.for_user(current_user).last_opened.positions.delete position
            end
          end
        end
        render json: nil, status: :ok
      else
        batch = Batch.for_user(current_user).where(barcode: @barcode).first rescue nil
        if batch && batch.count > 0
          @barcode.transaction do
            if @item.have_weight
              batch.count -= amount
              batch.locked_amount += amount
            else
              batch.count -= 1
              batch.locked_amount += 1
            end
            batch.save!
            if Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).try(:first)
              position = Receipt.for_user(current_user).last_opened.positions.where(batch: batch, item: @item).first
              if @item.have_weight
                position.count += amount
              else
                position.count += 1
              end
              position.save!
            else
              if @item.have_weight
                Receipt.for_user(current_user).last_opened.positions << Position.create(batch: batch, item: @item, count: amount, price: batch.price)
              else
                Receipt.for_user(current_user).last_opened.positions << Position.create(batch: batch, item: @item, count: 1, price: batch.price)
              end
            end
          end
          render json: @item.slice(:name).merge({price: batch.price * amount, code: @barcode.code})
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

    @item = Item.new
    @item.name = params['name']
    @item.have_weight = (params['have_weight'] == 'true')
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
    puts params['have_weight']
    @item.name = params['name']
    @item.have_weight = (params['have_weight'] == 'true')
    if @item.save
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
      params.permit(:name, :have_weight)
    end
end
