class Api::V1::Calendar::RegularCalendarController < ApplicationController

  # その日を含む週(日~月)のregularを返す
  def date
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:date].to_i)
    @calendar = ::RegularCalendar.new(date)
    render json: @calendar.renderer
  end

end
