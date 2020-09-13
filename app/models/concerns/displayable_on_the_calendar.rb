module DisplayableOnTheCalendar
    extend ActiveSupport::Concern

    # 1レコード1日程を表していない子モデルもあるから、インスタンスメソッドでなく、関数を提供するイメージ　＝＞モジュール関数
    

    module ClassMethods
        # st..ed間の予をlist型(要素はハッシュ)を返す。これはそのままjsonに変換される
        def between(st,ed)
            raise NotImplementedError
        end
    end

    # Calendarクラスを取得するインターフェース
    def calendar
        Calendar.new
    end

    # SECTIONで、指定されたidに対応するものをtime型に変換して返す
    def table(section_id)
        sec = SECTION[section_id]
        sec.map{|s| Time.zone.parse(s)}
    end

    # SECTIONに対応するidを返す
    def section_id
        st, ed = time_start.strftime("%H:%M:%S"), time_end.strftime("%H:%M:%S")
        SECTION.index([st,ed])
    end   

    # SECTIONで、指定されたidに対応するものをtime型に変換して返す
    def included_in_section?
        !!section_id
    end


    #タイムテーブルの時間割
    SECTION = [
        ["09:00:00", "11:00:00"],
        ["11:00:00", "13:00:00"],
        ["13:00:00", "15:00:00"],
        ["15:00:00", "17:00:00"],
        ["17:00:00", "18:30:00"],
        ["18:30:00", "20:00:00"],
    ]

end