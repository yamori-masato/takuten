class Recurring < ApplicationRecord
  with_options presence: true do
      validates :date_start
      validates :time_start
      validates :time_end
  end
  validate :validate_between_time_start_to_time_end

  has_many :exception_times, dependent: :destroy

  extend TimeFormatter
  time_format_filter(:time_start, :time_end)




  private
      # def validate_between_date_start_to_date_end
      #     if errors.full_messages.empty? && date_start >= date_end
      #         errors.add(:base,'date_endはdate_startより後に設定してください')
      #     end
      # end
      def validate_between_time_start_to_time_end
          if errors.full_messages.empty? && time_start_f >= time_end_f
          errors.add(:base,'time_endはtime_startより後に設定してください')
          end
      end
end
