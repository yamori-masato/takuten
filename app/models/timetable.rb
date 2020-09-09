class Timetable
    include ActiveModel::Model

    def initialize
        @class_list = [
            Activity::Regular,
            Activity::Nonregular,
        ]
    end


    #st(date)から1ヶ月間の全ての予定(hash配列)を返す(Calendar#index)
    def one_month_occurrences(st,band_id:nil)
        st = st.to_date
        ed = st.next_month
        occurs_between(st,ed,band_id:band_id)
    end

    #dateの1日間の全ての予定を返す(Calendar#show)
    def one_day_occurrences(date,band_id:nil)
        date = date.to_date
        occurs_between(date,date,band_id:band_id)
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
            @class_list.each do |c|
                all_occurrences += c.between(st,ed,band_id:band_id)
            end
            all_occurrences.sort_by!{|a| a[:date].to_date}
        end



end

