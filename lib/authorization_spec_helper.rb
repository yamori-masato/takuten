module AuthorizationSpecHelper
    def sign_in(user)
      post "/login",
        params: { name: user[:name], password: user[:password]},
        as: :json
      response.body
    end
  end