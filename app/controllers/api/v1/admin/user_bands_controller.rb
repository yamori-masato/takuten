module Api
  module V1
    module Admin
      class UserBandsController < ApplicationController
        before_action :set_user_band, only: [:show, :update, :destroy]

        # GET /user_bands
        def index
          @user_bands = UserBand.all

          render json: @user_bands
        end

        # GET /user_bands/1
        def show
          render json: @user_band
        end

        # POST /user_bands
        def create
          @user_band = UserBand.new(user_band_params)

          if @user_band.save
            render json: @user_band, status: :created, location: @user_band
          else
            render json: @user_band.errors, status: :unprocessable_entity
          end
        end

        # PATCH/PUT /user_bands/1
        def update
          if @user_band.update(user_band_params)
            render json: @user_band
          else
            render json: @user_band.errors, status: :unprocessable_entity
          end
        end

        # DELETE /user_bands/1
        def destroy
          @user_band.destroy
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_user_band
            @user_band = UserBand.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def user_band_params
            params.require(:user_band).permit(:user_id, :band_id)
          end
      end
    end
  end
end