class ApplicationController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods
    before_action :authenticate
    
    def current_user
        authenticate_or_request_with_http_token do |token,options|
            User.find_by(token: token)
        end
    end

    def authenticate
        authenticate_or_request_with_http_token do |token,options|
          auth_user = User.find_by(token: token)
          auth_user != nil ? true : false
        end
    end
end
