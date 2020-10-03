class Activity::Regular < Recurring
    include ActivityMixin
    after_create :create_exception_if_already_booked

    scope :ds_lteq, -> (date){ where(self.arel_table[:date_start].lteq(date)) } # date >= :date_start
    scope :ds_gteq, -> (date){ where(self.arel_table[:date_start].gteq(date)) } # date <= :date_start
    scope :de_lteq, -> (date){ where(self.arel_table[:date_end].lteq(date)) } # date >= :date_end
    scope :de_gteq, -> (date){ where(self.arel_table[:date_end].gteq(date)) } # date <= :date_end

    #指定期間中の該当する日付のリストを返す。例 ["2020-09-02", "2020-09-09", ...]
    def occurs_between(st,ed)
        schedule = IceCube::Schedule.new(now = self.date_start)
        schedule.add_recurrence_rule(IceCube::Rule.weekly)
        self.exception_times.each do |et|
            schedule.add_exception_time(et.date)
        end
        schedule.occurrences_between(st,ed).map{|o| o.to_date.to_s}
    end

    def occurs_on?(date)
        occurs_between(date,date).present?
    end
    
    #曜日を返す(日~土: 0~6)
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

        
    # ①dateを跨ぐものはそこで打ち切って(date_endを設定)、date_start=dateとしてあらたに作成(続きを別時間で作成)
    # ②跨がない。且つdateより先のものはレコード自体を削除して新たに別時間に設定し作成
    def self.shift_time_of_all_subsequent_schedules(st,ed=nil,old_sections)
    end

    # ①dateを跨ぐものはそこで打ち切る
    # ②跨がない。且つdateより先のものは予定はレコード自体を削除
    def self.delete_all_subsequent_schedules(date)
        pattern1 = self.de_gteq(date).or(self.where(date_end: nil)).ds_lteq(date) # ①
        pattern2 = self.ds_gteq(date)                                             # ②
        self.transaction do
            pattern1.each { |record| record.update!(date_end: date-1.days) } 
            pattern2.each { |record| record.destroy! } 
            # ----------------------------------------------------ExceptionTimeも削除
        end
    end

    def date_start
        attributes["date_start"]
    end

    def time_start
        attributes["time_start"]
    end

    def time_end
        attributes["time_end"]
    end




    MS = Time.current.beginning_of_month.to_date
    MM = MS.since(14.days)
    ME = Time.current.end_of_month.to_date

    private
        #繰り返しのどこかで予約が2つある、又は自身のバンドの非正規コマと被る場合、そこだけ外す(ExceptionTimeを作成する)。
        def create_exception_if_already_booked
            last = Onetime.maximum(:date)
            if last #1つもデータがない時nilを返す
                occurs_between(date_start,last).each do |occurrence|#日付
                    os = one_day_occurrences(occurrence)
                    if os.find_all{|o| o[:time_start] == time_start_f && o[:time_end] == time_end_f}.length >= 3 #新たに追加したらコマ3被り
                        self.exception_times.build(date: occurrence).save! #除外の追加
                    elsif os.find_all{|o| o[:time_start] == time_start_f && o[:time_end] == time_end_f && o[:band_id] == band_id}.length >= 2 #新たに追加したら自身のバンドの非正規コマと被り
                        self.exception_times.build(date: occurrence).save! #除外の追加
                    end
                end
            end
        end
    
end
# ※has_one - belong_to 関連付けの注意点

# ① band.build_regularで作成すると、既に関連があった場合deleteされてしまう。
#
# なので、controller内では愚直に
#
# band = band.find(1)
#
# r = regular.new(date_start: ...)
# if band.regular.nil?
#   r.save!
#   band.regular = r                             ...(★)
#
# のように書いたほうがいい


# ② band.regularは常にuniqueになるが(①)、Regularレコードでband_id==1のものは1つとは限らない
#
# もし、既に Band(id:1)とRegular(id:1)が紐づいているとして
# 新たに、r2 = Regular.create(..., band_id: 1)とした場合
# r2レコードは保存されるが、band.regular.idは1のままである。
# 
# ①の ★ の行で、勝手にRegular(id:1)が消され(←大事)、新たに、band.regular.idが2となる。

# つまり、新たな関連を作成すれば旧関連のレコードは勝手に削除されるが、
# Regularレコードでband_idが同じものは、意図的に作れてしまう。(でもこれがないとそもそも ★ の行が書けなくなるから関連の変更ができなくなる?
