class Api::V1::RegularsController < ApplicationController
  def index
    @regulars = Activity::Regular.all
    render json: @regulars, each_serializer: RegularSerializer
  end

end
