FactoryBot.define do
  factory :recurring do
    date_start { Date.parse("2000/01/01") }
    time_start { Time.parse("09:00:00") }
    time_end { Time.parse("11:00:00") }
  end
end
