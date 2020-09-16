Rails.application.routes.draw do

  root to: 'users#index'
  post 'login/', to: 'login#login'


  namespace :api do
    namespace :v1 do


      # 管理者はuserまで触れる api/v1の外のがよさそう
      namespace :admin do
        resources :users do 
          resources :bands #admin側でネストする意味なさそう
        end
        resources :regulars, only: [:index, :show, :create, :update, :destroy]
      end

      # 一般利用者は、token有りのリクエストを送る事で自身や自身のバンドをみれる。
      resource :user, only: [:update, :show]
      resources :users, only: [:index]
      resources :bands do
        member do
          delete :leave# 自身のバンドから退会
        end

        #単発削除
        resource :regular, only: [:destroy]
        resource :nonregular, only: [:destroy]
      end
      
      #カレンダーと正規コマカレンダー(リソースベースではないもの)
      get 'calendar/:year/:month', to: 'calendar#month'
      get 'calendar/:year/:month/:date', to: 'calendar#date'
      get 'rcalendar/:year/:month/:date', to: 'regular_calendar#date'


    end
  end

end
