FactoryBot.define do
  allday = (Date.parse('2000-01-01')..Date.parse('2000-01-31')).to_a

  factory :nonregular, class: 'Activity::Nonregular', parent: :single do
    association :band, factory: :band, strategy: :build
  end

  factory :nonregular_allday_each_band, class: 'Activity::Nonregular', parent: :single do
    association :band, factory: :band, strategy: :build
    sequence(:date, allday.cycle )
  end

  factory :nonregular_allday, class: 'Activity::Nonregular', parent: :single do
    band_id{ 1 } #作成時に上書きする(遅延評価だからエラーにはならない)
    sequence(:date, allday.cycle )
  end
end