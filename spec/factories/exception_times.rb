FactoryBot.define do
    factory :exception_time, class: ExceptionTime do
        date { Date.parse("2000/01/01") }
        association :recurring, factory: :regular, strategy: :build
    end
end
  