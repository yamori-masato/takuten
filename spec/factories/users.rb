FactoryBot.define do

    factory :user, class: User do
        sequence(:name){|n| "user#{n}"}
        password {'pass'}
        password_confirmation {'pass'}
    end

end