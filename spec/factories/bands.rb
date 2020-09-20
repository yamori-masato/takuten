FactoryBot.define do
  factory :band, class: Band do
    sequence(:name){|n| "band#{n}"}
  end
end
