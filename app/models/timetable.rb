class Timetable < ApplicationRecord
    serialize :sections, Array # nil->[] となることに注意
    validates :date_start, presence: true
    validate :validate_section_format
    before_create :update_current_timetable

    scope :before, -> (date){ where(Timetable.arel_table[:date_start].lt(date)) } # :date < date_start
    scope :after, -> (date){ where(Timetable.arel_table[:date_start].gteq(date)) } # :date >= date_start
    scope :current, -> (date){ where(date_start: before(date).maximum(:date_start)).first }


    # strftimeされたsections
    def sections_f
        sections.map do |section|
            section.map{ |time| time.strftime("%H:%M:%S") }
        end
    end

    # SECTIONで、指定されたidに対応するもの返す
    def section(section_id)
        sections[section_id]
    end

    # strftimeされたsection
    def section_f(section_id)
        section(section_id).map{ |time| time.strftime("%H:%M:%S") }
    end

    # SECTIONに対応するindexを返す
    def section_index(ts,te)
        sec = [ts,te]
        sec.map!{ |t| t.strftime("%H:%M:%S") }
        sections_f.index(sec)
    end

    def delete_all_subsequent_schedules(date)
        Calendar.new.polymorphic.each do |p|
            p.delete_all_subsequent_schedules(date)
        end
    end

    SECTION_F = [
        ["09:00:00", "11:00:00"],
        ["11:00:00", "13:00:00"],
        ["13:00:00", "15:00:00"],
        ["15:00:00", "17:00:00"],
        ["17:00:00", "18:30:00"],
        ["18:30:00", "20:00:00"],
    ]

    SECTION = Timetable::SECTION_F.map{|s| s.map{|t| Time.parse(t)}}



    private
        def validate_section_format
            # n*2の長方行列
            unless sections.length > 0 && sections.all?{ |section| section.length==2 }
                errors.add(:base, "sections is improper format1")
                return
            end
            # 各要素のクラスは[Time, Time]
            sections.each do |time_start, time_end|
                valid_class = [ActiveSupport::TimeWithZone, Time]
                unless valid_class.include?(time_start.class) && valid_class.include?(time_start.class)
                    errors.add(:base, "sections is improper format2")
                    return
                end
                unless time_start.strftime("%H:%M:%S") < time_end.strftime("%H:%M:%S")
                    errors.add(:base, "sections is improper format3")
                end
            end
            # sectionがソートされているか、時間が被っていないか
            unless sections.each_cons(2).all? { |a, b| a[1].strftime("%H:%M:%S") <= b[0].strftime("%H:%M:%S")}
                errors.add(:base, "sections is improper format4")
            end
        end

        # 新しく作成するもの(ds,de)に対して、①ds<=ds'は全て削除 ②dsの直前のds' にde'=(ds-1.day) を設定
        def update_current_timetable
            Timetable.after(date_start).each{ |t| t.destroy } # ①
            Timetable.current(date_start).update(date_end: date_start-1.day) # ②
        end
end
