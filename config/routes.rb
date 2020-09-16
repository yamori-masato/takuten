Rails.application.routes.draw do


  post 'login/', to: 'login#login'


  namespace :api do
    namespace :v1 do


      # AdminUser-----------------------------------------------------
      namespace :admin do
        resources :users
        resources :bands do
          resources :nonregulars
          resources :regulars
        end
      end




      # User-----------------------------------------------------
      resource :user, only: [:update, :show]
      resources :users, only: [:index]
      resources :bands do
        delete :leave, on: :member# 自身のバンドから退会

        #単発削除
        resource :regular, only: [:destroy]
        resource :nonregular, only: [:create,:destroy]
      end
      
      scope module: :calendar do
        get 'calendar/:year/:month', to: 'calendar#month'
        get 'calendar/:year/:month/:date', to: 'calendar#date'
        get 'rcalendar/:year/:month/:date', to: 'regular_calendar#date'
      end

    end
  end

end
