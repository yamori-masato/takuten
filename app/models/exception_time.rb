class ExceptionTime < ApplicationRecord
    with_options presence: true do
        validates :date
        validates :recurring_id
    end

    belongs_to :recurring

end
