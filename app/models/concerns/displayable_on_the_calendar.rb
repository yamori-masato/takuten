module DisplayableOnTheCalendar
    extend ActiveSupport::Concern
    # 1レコード1日程を表していない子モデルもあるから、インスタンスメソッドでなく、関数を提供するイメージ　＝＞モジュール関数
    
    included do
        validate :validate_time_should_fit_the_section
    end

    module ClassMethods
        # st..ed間の予定をlist型(要素はハッシュ)を返す。これはそのままjsonに変換される
        def between(st,ed)
            raise NotImplementedError
        end

        # st..ed間の予定をsectionsに沿って移動させる。ed=nilの時は移行の予定全てが対象
        def time_shift(st,ed=nil,sections)
            raise NotImplementedError
        end

        # date以降の予定をすべて削除
        def delete_all_subsequent_schedules(date)
            raise NotImplementedError
        end
    end

    def time_start
        raise NotImplementedError
    end

    def time_end
        raise NotImplementedError
    end

    def date_start
        raise NotImplementedError
    end



    # Calendarクラスを取得するインターフェース
    def calendar
        Calendar.new
    end

    # dateに対応するTimetableインスタンスを返す
    def timetable(date)
        Timetable.current(date)
    end

    private
        # Timetableの区分に一致を強制
        def validate_time_should_fit_the_section
            unless timetable(date_start).section_index(time_start, time_end)
                errors.add(:base, "time_start and time_end must fit timetable's section")
            end
        end
end