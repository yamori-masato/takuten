module Api
  module V1
    class UserBandsController < ApplicationController
        before_action :set_user_band, only: [:update, :destroy]


        
        def create
          @user_band = UserBand.new(user_band_params)

          if @user_band.save
            render json: @user_band, status: :created, location: @user_band
          else
            render json: @user_band.errors, status: :unprocessable_entity
          end
        end

        
        def destroy
          @user_band.destroy
        end


        private

          # Only allow a trusted parameter "white list" through.
          def user_band_params
            params.require(:user_band).permit(:user_id, :band_id)
          end

    end
  end
end