module DisplayableOnTheCalendar
    extend ActiveSupport::Concern


    

    module ClassMethods
        # st..ed間の予をlist型(要素はハッシュ)を返す。これはそのままjsonに変換される
        def between(st,ed)
            raise NotImplementedError
        end

    end
end