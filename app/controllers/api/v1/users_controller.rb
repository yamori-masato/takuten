
class Api::V1::UsersController < ApplicationController
  # include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :authenticate
  before_action :set_current_user, only: [:show, :update]
  

  # GET /users
  def index
    @users = User.all
    render json: @users, each_serializer: UserSerializer
  end

  # GET /user
  def show
    render json: @user, serializer: UserSerializer
  end

  # PATCH/PUT /user
  def update
    if @user.update(user_params)
      render json: @user, serializer: UserSerializer
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
      params.permit(:nickname)
    end


end


