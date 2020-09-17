class Onetime < ApplicationRecord
  with_options presence: true do
      validates :date
      validates :time_start
      validates :time_end
  end
  validate :validate_between_time_start_to_time_end

  extend TimeFormatter
  time_format_filter(:time_start, :time_end)


  
  private
      def validate_between_time_start_to_time_end
          if errors.full_messages.empty? && time_start_f >= time_end_f
          errors.add(:base,'time_endはtime_startより後に設定してください')
          end
      end
end