FactoryBot.define do
  t = Time.parse("2000/01/01 00:00:00")
  factory :recurring do
    date_start { t.to_date }
    date_end { t.yesterday.to_date }
    time_start { t.to_time }
    time_end { t.since(1.hours).to_time }
  end
end
