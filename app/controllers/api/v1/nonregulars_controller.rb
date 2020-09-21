class Api::V1::NonregularsController < ApplicationController
  before_action :authenticate
  before_action :set_current_users_band, only: [:index, :destroy, :create]
  before_action :set_bands_nonregular, only: [:destroy]

  def index
    @nonregulars = @band.nonregulars.all
    render json: @nonregulars, each_serializer: NonregularSerializer
  end

  def create
    @nonregular = @band.nonregulars.build(nonregular_params)
    if @nonregular.save
      render json: @nonregular, serializer: NonregularSerializer, status: :created#201 
    else
      render json: @nonregular.errors, status: :unprocessable_entity#422
    end
  end


  def destroy
    @nonregular.destroy
    render plain: "successfully deleted"
  end




  private
    def set_current_users_band
      @band = current_user.bands.find_by(id: params[:band_id])
      unless @band
        render plain: "Band(id: #{params[:band_id]}) is not found", status: :not_found#404
      end
    end

    def set_bands_nonregular
      @nonregular = @band.nonregulars.find_by(id: params[:id])
      unless @nonregular
        render plain: "#{@band.name}'s Nonregular(id: #{params[:id]}) is not found", status: :not_found#404
      end
    end

    def nonregular_params
      params.permit(:date, :time_start, :time_end, :index)
    end
end
