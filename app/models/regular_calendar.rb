class RegularCalendar

    def initialize(date)
        @regular = Activity::Regular
        @timetable = Timetable

        @st = date.beginning_of_week - 1.day # その週の週初め(日)
        @ed = date.end_of_week - 1.day # その週の週終わり(月)

        @occurrences = @regular.between(@st, @ed)
    end


    #occurrencesを変換(プレゼンテーション層だから少し違和感)
    def renderer
        os = @occurrences.group_by{|o| o[:date]} # これだけだとコマが1つもない日が抜ける
        (@st..@ed).each do |date|
            date = date.to_s
            os[date] = [] unless os[date]
        end

        week = %w(sunday monday tuesday wednesday thursday friday saturday)

        oss = os.map{ |date, o| {day: week[Date.parse(date).wday], sections: fill(o, date)} }
        oss.sort_by!{ |os| week.index(os[:day]) }
    end


    private

        def fill(os,date)
            sections = @timetable.current(date).sections_f
            sections.map do |section|
                ts, te = section
                none = {time_start: ts, time_end: te, state: "AVAILABLE"}
                exist = os.count{|os| os[:time_start]==ts && os[:time_end]==te}
                num = 2 - exist
                num.times { os.append(none) }
            end

            os.each do |o|
                o.delete(:date)
                o.delete(:type_id)
                o.delete(:type)
                o[:band] = {id: o[:band_id], name: Band.find(o[:band_id]).name} if o[:band_id].present?
                o.delete(:band_id)
            end.sort_by!{|o| o[:time_start]}
        end
end