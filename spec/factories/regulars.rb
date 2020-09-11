FactoryBot.define do
  factory :regular, class: 'Activity::Regular', parent: :recurring do
    association :band, factory: :band, strategy: :build
  end
end
