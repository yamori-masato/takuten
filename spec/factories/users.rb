FactoryBot.define do

    factory :user, class: User do
        name {'user'}
        password {'pass'}
        password_confirmation {'pass'}
    end

end