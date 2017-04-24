class BarcodesController < ApplicationController
  before_action :set_barcode, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @barcode = Barcode.where(item_id: params[:item_id])
    render json: @barcode
  end

  # GET /items/1


  # POST /items
  # POST /items.json
  def create
    @barcode = Barcode.new
    @barcode.code = params[:code]
    @barcode.item = Item.find(params[:item_id])
    respond_to do |format|
      if @barcode.save
        format.json { render json: @barcode, status: :created, location: @item }
      else
        format.json { render json: @barcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    @barcode.code = params[:code]
    @barcode.item = Item.find(params[:item_id])
    respond_to do |format|
      if @barcode.save
        format.json { render json: @barcode, status: :ok }
      else
        format.json { render json: @barcode.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @barcode.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_barcode
      @barcode = Barcode.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def barcode_params
      params.require([:code, :count])
    end
end
