class Api::V1::Calendar::RegularCalendarController < ApplicationController

  # その日を含む週(日~月)のregularを返す
  def date
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:date].to_i)
    bow = date.beginning_of_week - 1.day # その週の週初め(日)
    eow = date.end_of_week - 1.day # その週の週終わり(月)
    @calendar = Activity::Regular.between(bow,eow)
    render json: @calendar
  end

end
