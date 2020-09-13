class Activity::Nonregular < Onetime
    include ActivityMixin
    validate :validate_triple_booking
    validate :validate_cannot_book_at_the_same_time

    include DisplayableOnTheCalendar
    # start~endまでに存在する非正規コマのイベントをhashで返す
    def self.between(st,ed,band_id:nil)
        nonregulars = self.where(date: st..ed)
        nonregulars = nonregulars.band(band_id) if band_id
        nonregulars.map do |nonregular|
            {
                type: "Nonregular",
                type_id: nonregular.id,
                date: nonregular.date.to_s,
                time_start: nonregular.time_start_f,
                time_end: nonregular.time_end_f,
                band_id: nonregular.band_id,
            }
        end
    end


    MS = Time.current.beginning_of_month.to_date
    MM = MS.since(14.days)
    ME = Time.current.end_of_month.to_date


    private
        def validate_triple_booking
            os = calendar.one_day_occurrences(date)#その日の全ての予定(hash配列)
            if os.find_all{|o| o[:time_start] == time_start_f && o[:time_end] == time_end_f }.length >= 2
                errors.add(:base,'そのコマは既に他の予約で埋まっています。')
            end
        end

        def validate_cannot_book_at_the_same_time
            os = calendar.one_day_occurrences(date)#その日の全ての予定(hash配列)
            if !os.find_all{|o| o[:time_start] == time_start_f && o[:time_end] == time_end_f && o[:band_id] == band_id}.empty?
                errors.add(:base,"同じコマは2つ以上予約できません。")
            end
        end



end
