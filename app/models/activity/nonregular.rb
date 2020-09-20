class Activity::Nonregular < Onetime
    include ActivityMixin
    validate :validate_triple_booking
    validate :validate_cannot_book_at_the_same_time
    before_validation :string_to_date, :string_to_time

    scope :ds_lteq, -> (date){ where(self.arel_table[:date].lteq(date)) } # date >= :date
    scope :ds_gteq, -> (date){ where(self.arel_table[:date].gteq(date)) } # date <= :date

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

    def self.shift_time_of_all_subsequent_schedules(st,ed=nil,old_sections)
    end

    def self.delete_all_subsequent_schedules(date)
        self.ds_gteq(date).destroy_all
    end
    

    def date_start
        date
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

        def string_to_date
            self.date = Date.parse(self.date) if self.date.class == String
        end
        def string_to_time
            self.time_start = Time.parse(self.time_start) if self.time_start.class == String
            self.time_end = Time.parse(self.time_end) if self.time_end.class == String
        end



end
