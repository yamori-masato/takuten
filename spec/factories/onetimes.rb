FactoryBot.define do
  factory :onetime do
    date { Time.current.to_date }
    time_start { Time.parse("09:00:00") }
    time_end { Time.parse("11:00:00") }
  end
end