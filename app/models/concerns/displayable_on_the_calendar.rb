module DisplayableOnTheCalendar
    extend ActiveSupport::Concern
    # 1レコード1日程を表していない子モデルもあるから、インスタンスメソッドでなく、関数を提供するイメージ
    # betweenは、ハッシュじゃなくてオブジェクトを返すように定義させたほうが良さそう。srializerつかったりできる。
    
    included do
        validate :validate_time_should_fit_the_section
    end

    module ClassMethods
        # st..ed間の予定をlist型(要素はハッシュ)を返す。これはそのままjsonに変換される
        def between(st,ed)
            raise NotImplementedError
        end

        # st..ed間の予定をsectionsに沿って移動させる。ed=nilの時は移行の予定全てが対象
        def shift_time_of_all_subsequent_schedules(st,ed=nil,old_sections)
            raise NotImplementedError
        end

        # date以降の予定をすべて削除
        def delete_all_subsequent_schedules(date)
            raise NotImplementedError
        end
    end

    # 必須プロパティ
    def time_start
        raise NotImplementedError
    end

    def time_end
        raise NotImplementedError
    end

    def date_start
        raise NotImplementedError
    end

    # dateに対応するTimetableインスタンスを返す
    def timetable(date)
        Timetable.current(date)
    end

    # Calendarクラスを取得するインターフェース
    def calendar
        Calendar.new
    end


    private

        # Timetableの区分に一致を強制
        def validate_time_should_fit_the_section
            unless timetable(date_start).section_index(time_start, time_end)
                errors.add(:base, "time_start and time_end must fit timetable's section")
            end
        end



        # カレンダーのバリデーションを各子モデルに切り出しているのが汚い。せめて、DisplayOnTheCalendarの為のバリデーションってわかるようにラップできたら。(制約が後から追加された感覚だからモジュール内に閉じ込めたい)
        # Timetableのように、全子モデル共通のバリデーションなら、モジュール内に記述してincludeさせればいいけど、
        # 子モデルごとでバリデーションの挙動が違う且つ、バリデーション自体が任意であるとき困る(Calendar)
end


