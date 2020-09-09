class Activity::Regular < Recurring
    include ActivityMixin
    after_create :create_exception_if_already_booked

    #指定期間中の該当する日付のリストを返す。例 ["2020-09-02", "2020-09-09", ...]
    def occurs_between(st,ed)
        schedule = IceCube::Schedule.new(now = self.date_start)
        schedule.add_recurrence_rule(IceCube::Rule.weekly)
        self.exception_times.each do |et|
            schedule.add_exception_time(et.date)
        end
        schedule.occurrences_between(st,ed).map{|o| o.to_date.to_s}
    end
    
    #曜日を返す(日~月: 0~6)
    def week
        self.date_start.wday
    end


    include DisplayableOnTheCalendar
    #start~endまでに存在する正規コマのイベントをhashで返す
    def self.between(st,ed,band_id:nil)
        regulars = where(Activity::Regular.arel_table[:date_start].lteq(ed))# Activity::Regularオブジェクトで、date_startがed以下のもの
        regulars = regulars.band(band_id) if band_id
        regulars.map do |regular|
            regular.occurs_between(st,ed).map do |date|
                {
                    type: "Regular",
                    type_id: regular.id,
                    date: date,
                    time_start: regular.time_start_f,
                    time_end: regular.time_end_f,
                    band_id: regular.band_id,
                }
            end
        end.flatten
    end





    MS = Time.current.beginning_of_month.to_date
    MM = MS.since(14.days)
    ME = Time.current.end_of_month.to_date

    private
        #繰り返しのどこかで予約が2つあったらそこだけ外す(ExceptionTimeを作成する)。
        def create_exception_if_already_booked
            last = Onetime.maximum(:date)
            if last #1つもデータがない時nilを返す
                t = Timetable
                occurs_between(date_start,last).each do |occurrence|#日付
                    os = t.new.one_day_occurrences(occurrence)
                    if os.find_all{|o| o[:time_start] == time_start_f}.length >= 3 #新たに追加したらコマ3被り
                        self.exception_times.build(date: occurrence).save! #除外の追加
                    end
                end
            end
        end

        #正規コマは1バンド1つしか登録できない(これがないとnewで更新されてしまう)↓new時(バリデーションより前)に古いデータが消されてしまう仕様らしいから意味ない
        # def validate_cannot_register_twice
        #     band = Band.find(band_id)
        #     if band.regular
        #         errors.add(:base,"正規コマは2つ以上登録できません。")
        #     end
        # end




        
end