require "rails_helper"



RSpec.describe "Api::V1::RegularCalendar", type: :request do
    before do
        load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb")) # seed/test を呼び出し
    end

    let(:user) { User.first }
    let(:user_params) { {name: user.name, password: "pass"} }

    describe "CalendarAPI" do
        let(:year) { 2000 }
        let(:month) { 1 }
        let(:date) { 1 }

        describe "GET /api/v1/rcalendar/:year/:month/:date" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/rcalendar/#{year}/#{month}/#{date}"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "1週間の予定を取得(200)" do
                    get "/api/v1/rcalendar/#{year}/#{month}/#{date}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)

                    expect(response.status).to eq(200)
                    # 以下でフォーマットを確認
                    expect(json.length).to eq(7)
                    week = %w(sunday monday tuesday wednesday thursday friday saturday)
                    json.zip(week) do |day, d|
                        expect(day["day"]).to eq(d)
                        expect(day["sections"].length).to eq(12)
                    end
                end
            end
        end
    end
end