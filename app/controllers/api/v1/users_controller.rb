module Api
  module V1
    class UsersController < ApplicationController
      # include ActionController::HttpAuthentication::Token::ControllerMethods
      before_action :authenticate
      before_action :set_current_user, only: [:show, :update]
      

      # GET /users
      def index
        @users = User.all
        render json: @users
      end

      # GET /user
      def show
        render json: @user
      end

      # PATCH/PUT /user
      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_current_user
          @user = current_user
        end

        # Only allow a trusted parameter "white list" through.
        def user_params
          # logger.debug("--------------------------")
          # logger.debug(params)
          # logger.debug("--------------------------")
          params.permit(:name, :nickname, :grade)
        end


    end

  end
end
