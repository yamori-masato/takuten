class Timetable < ApplicationRecord
    serialize :sections, Array # nil->[] となることに注意
    validates :date_start, presence: true
    validate :validate_section_format
    before_create :update_current_timetable

    scope :before, -> (date){ where(Timetable.arel_table[:date_start].lt(date)) } # :date < date_start
    scope :after, -> (date){ where(Timetable.arel_table[:date_start].gteq(date)) } # :date >= date_start
    scope :current, -> (date){ where(date_start: before(date).maximum(:date_start)) }


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
                unless time_start < time_end
                    errors.add(:base, "sections is improper format3")
                end
            end
            # sectionがソートされているか、時間が被っていないか
            unless sections.each_cons(2).all? { |a, b| a[1] <= b[0]}
                errors.add(:base, "sections is improper format4")
            end
        end

        # 新しく作成するもの(ds,de)に対して、①ds<=ds'は全て削除 ②dsの直前のds' にde'=(ds-1.day) を設定
        def update_current_timetable
            Timetable.after(date_start).each{ |t| t.destroy } # ①
            Timetable.current(date_start).update(date_end: date_start-1.day)
        end
end
