class ExceptionTime < ApplicationRecord
    with_options presence: true do
        validates :date
        validates :recurring_id
    end
    validate :validate_match_recurring_pattern

    belongs_to :recurring


    private
        # dateがRegularの繰り返し内に含まれるか
        def validate_match_recurring_pattern
            return if errors.full_messages.present?
            
            parent = Activity::Regular.find(self.recurring_id)
            unless parent.occurs_on?(self.date)
                errors.add(:base, "#date(#{date})が正規コマに一致しません")
            end
        end
end
