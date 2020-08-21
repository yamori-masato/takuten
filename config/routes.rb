Rails.application.routes.draw do
  
  root to: 'users#index'
  post 'login/login'

  
  namespace :api do
    namespace :v1 do


      # 管理者はuserまで触れる
      namespace :admin do
        resources :users do 
          resources :bands #my band controll
        end
      end

      # 一般利用者は、token有りのリクエストを送る事で自身や自身のバンドをみれる。
      resource :user, only: [:update, :show]
      resources :bands do
        # 自身のバンドへの加入と退会
        member do
          # post :join
          patch :leave
        end
      end
      

    end
  end

end
