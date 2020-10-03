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
        resources :timetable
      end


      # User-----------------------------------------------------
      resource :user, only: [:update, :show]                              # 自身
      resources :users, only: [:index]                                    # 全部員
      resources :bands do                                                 # 自身のバンド
        delete :leave, on: :member                                          # 自身のバンドから退会


        resources :nonregulars, only: [:index, :create, :destroy]           # 非正規コマ ~~~~indexはデバック用
        resource :regular do
          post :except, on: :member                                         # 正規コマ単発削除(例外作成) Regular(親)#except = ExceptionTime(子)#create
          # get :next, on: :member
        end 
      end
      

      # Commn-----------------------------------------------------
      scope module: :calendar do
        get 'calendar/:year/:month', to: 'calendar#month'
        get 'calendar/:year/:month/:date', to: 'calendar#date'
        get 'rcalendar/:year/:month/:date', to: 'regular_calendar#date'
      end

    end
  end
end
