class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_item_from_barcode, only: :search

  # GET /items
  # GET /items.json
  def index
    @items = Item.where(user: current_user)
  end

  # GET /items/1
  # GET /items/1.json
  def show
    render layout: false
  end

  def search
    if @item
      render json: @item.slice(:name, :price).merge({code: @barcode.code})
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
    puts item_params.inspect
    @item.valid?
    puts @item.errors.full_messages
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
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    def set_item_from_barcode
      @barcode = Barcode.for_user(current_user).find_by_code(params[:barcode])
      @item = @barcode.try(:item)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.permit(:name, :price)
    end
end
