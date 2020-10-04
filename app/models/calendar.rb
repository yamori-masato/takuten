class Calendar
    # include ActiveModel::Model
    # Timetableでpolymorphicを参照しただけなのに、わざわざCalendar.newしているのが汚い
    # でもクラス変数とかにすると自動読み込みの影響が出そう(要検証)。インスタンス化がreloadの役目になっているからこっちならまず安心。


    def initialize(st: Date.today, ed: Date.today, current_user: nil, band_id: nil)
        @polymorphic = [
            Activity::Regular,
            Activity::Nonregular,
        ]
        @timetable = Timetable
        @current_user = current_user
        @band_id = band_id
        @st = st.to_date
        @ed = ed.to_date

        @occurrences = occurs_between(@st, @ed, band_id:@band_id)
    end
    attr_reader :occurrences


    #occurrencesを変換(プレゼンテーション層だから少し違和感)
    def renderer
        os = @occurrences.group_by{|o| o[:date]} # これだけだとコマが1つもない日が抜ける
        (@st..@ed).each do |date|
            date = date.to_s
            os[date] = [] unless os[date]
        end

        oss = os.map{ |date, o| {date: date, sections: fill(o, date)} }
        oss.length == 1 ? oss[0] : { month: @st.strftime("%Y-%m"), dates: oss} #[{}]の形になってしまうからoss[0]
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


end

