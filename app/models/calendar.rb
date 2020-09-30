class Calendar
    # include ActiveModel::Model

    # インスタンスベースにする意味はあるのか？クラス変数(@@)でもよくないか
    # _occurrencesメソッドはモデルでいうModel.where()にあたるからクラスメソッドであるべき？でもCalendarインスタンス=イベント1つ1つではないからこれも変
    # そもそもひとつひとつをリストの要素にするより、calendarクラスのインスタンスにしたほうが綺麗？でも表示専門のインターフェースとして見ればやりすぎな気もする
    # 表示用のインターフェースとして捉えるなら、「Calendarを新たに取得(生成)する」という意味合いではいい気もする。(もしかしたら自動読み込みの関係でreloadが必要になるかも)

    def initialize(current_user: nil, band_id: nil)
        @polymorphic = [
            Activity::Regular,
            Activity::Nonregular,
        ]
        @timetable = Timetable

        # option
        @current_user = current_user
        @band_id = band_id
    end

    #st(date)から1ヶ月間の全ての予定(hash配列)を返す
    def one_month_occurrences(st)
        st = st.to_date # Date#to_dateを定義されているから保険用
        ed = st.next_month - 1.days
        occurs_between(st,ed,band_id:@band_id)
    end

    #dateの1日間の全ての予定を返す
    def one_day_occurrences(date)
        date = date.to_date
        occurs_between(date,date,band_id:@band_id)
    end

    #occurrencesを変換(プレゼント層だから少し違和感)
    def renderer(os, date)
        { "date" => date, "sections" => fill(os,date)}
    end

    def fill(os,date)
        sections = @timetable.current(date).sections_f
        sections.map do |section|
            ts, te = section
            none = {date: date, time_start: ts, time_end: te, state: "AVAILABLE"}
            exist = os.count{|os| os[:time_start]==ts && os[:time_end]==te}
            num = 2 - exist
            num.times { os.append(none) }
        end

        os.each do |o|
            o.delete(:date)
            if o[:band_id] && @current_user
                o[:state] = @current_user.bands.find_by(id: o[:band_id]) ? "YOUS" : "OTHERS"
            end
        end.sort_by!{|o| o[:time_start]}
    end




    #同時刻に3つ以上の予約はできない(Nonregularの作成時のみ)
    #子モデルによってバリデーション分けたほうがいい気がする。(優先順位に応じて)Nonregular<Regular<Event #各クラス内のバリデーションで書けそう
    #Nonregular: トリプルブッキングなし
    #Regular: 繰り返しの中でeventがある日は、作成時に繰り返しから除外
    #Event: バリデーションなし


    MS = Time.current.beginning_of_month
    MM = MS.since(14.days)
    ME = Time.current.end_of_month.to_date
    T = Time.current


    private
        #stからed間の全ての予定を返す
        def occurs_between(st,ed,band_id:nil)
            all_occurrences = []
            @polymorphic.each do |c|
                all_occurrences += c.between(st,ed,band_id:band_id)
            end
            all_occurrences.sort_by!{|a| a[:date].to_date}
        end



end

