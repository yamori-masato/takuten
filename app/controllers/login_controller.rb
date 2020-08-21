class LoginController < ApplicationController
  def login
    logger.debug("--------------------------")
    logger.debug(params)
    logger.debug("--------------------------")

    user = User.find_by(name: params[:name])
    login_user = user&.authenticate(params[:password])

    if login_user
      render plain: login_user.token
    else
      render plain: 'no auth'
    end
  end
end
