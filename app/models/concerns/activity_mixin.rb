module ActivityMixin
    extend ActiveSupport::Concern

    included do
        belongs_to :band
        scope :band, -> (id){ where(band_id: id) }
    end

    module ClassMethods
        # SECTIONで、指定されたidに対応するものをtime型に変換して返す
        def table(section_id)
            sec = SECTION[section_id]
            sec.map{|s| Time.zone.parse(s)}
        end

        def section_id(time_start, time_end)
            st, ed = time_start.strftime("%H:%M:%S"), time_end.strftime("%H:%M:%S")
            SECTION.index([st,ed])
        end   
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