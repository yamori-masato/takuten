class Api::V1::RegularsController < ApplicationController
  before_action :set_current_users_band, only: [:except, :show]
  before_action :set_bands_regular, only: [:except]


  # def show
  #   date = Date.new(params[:year].to_i, params[:month].to_i, 1)#月初め
  #   @calendar = Calendar.new.one_month_occurrences(date)
  #   render json: @calendar
  # end

  def show#デバック用
    @regulars = @band.regulars
    render json: @regulars, each_serializer: RegularSerializer
  end

  def except
    @exception_time = @regular.exception_times.build(exception_time_params)
    if @exception_time.save
      render json: @exception_time, serializer: ExceptionTimeSerializer, status: :created#201 
    else
      render json: @exception_time.errors, status: :unprocessable_entity#422
    end
  end





  private
  def set_current_users_band
    @band = current_user.bands.find_by(id: params[:band_id])
    unless @band
      render plain: "Band(id: #{params[:band_id]}) is not found", status: :not_found#404
    end
  end

  def set_bands_regular
    @params = exception_time_params
    @regular = @band.regulars.find{|regular| regular.occurs_on?(Date.parse(@params[:date]))}
    unless @regular
      render plain: "#{@band.name} have no plans to practice on that day", status: :unprocessable_entity#422
    end
  end

  def exception_time_params
    params.permit(:date)
  end
end
