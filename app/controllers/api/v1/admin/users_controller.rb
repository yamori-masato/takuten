module Api
  module V1
    module Admin
      class UsersController < ApplicationController
        before_action :set_user, only: [:show, :update, :destroy]
        # wrap_parameters :user

        # GET /users
        def index
          @users = User.all

          render json: @users
        end

        # GET /users/1
        def show
          render json: @user
        end

        # POST /users
        def create
          @user = User.new(user_params)
          @user.bands << user_bands

          if @user.save
            render json: @user, status: :created, location: @user
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        end

        # PATCH/PUT /users/1
        def update
          if @user.update(user_params) 
            @user.bands.clear
            @user.bands << user_bands
            render json: @user
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        end

        # DELETE /users/1
        def destroy
          @user.destroy
          render plain: "successfully deleted '#{@user.name}''"
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_user
            @user = User.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def user_params
            params.require(:user).permit(:name, :nickname, :password, :password_confirmation, :admin, :grade)

          end

          def user_bands
            para = params.require(:user).permit({band_ids: []})

            # logger.debug("--------------------------")
            # logger.debug(para)
            # logger.debug("--------------------------")
            
            if  para.empty?
              []
            else
              para["band_ids"].map{|id| Band.find(id)}
            end
          end
      end
    end
  end
end
