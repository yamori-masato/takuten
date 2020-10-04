require "rails_helper"



RSpec.describe "Api::V1::Calendar", type: :request do
    before do
        load(Rails.root.join('db', 'seeds', "#{Rails.env.downcase}.rb")) # seed/test を呼び出し
    end

    let(:user) { User.first }
    let(:user_params) { {name: user.name, password: "pass"} }

    describe "CalendarAPI" do
        let(:year) { 2000 }
        let(:month) { 1 }
        let(:date) { 1 }

        describe "GET /api/v1/calendar/:year/:month/:date" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/calendar/#{year}/#{month}/#{date}"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "1日分の予定を取得(200)" do
                    get "/api/v1/calendar/#{year}/#{month}/#{date}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)

                    expect(response.status).to eq(200)
                    # 以下でフォーマットを確認
                    expect(json["date"]).to eq(Date.parse("#{year}/#{month}/#{date}").to_s)
                    expect(json["sections"].length).to eq(12)
                end
            end

        end

        describe "GET /api/v1/calendar/:year/:month" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/calendar/#{year}/#{month}"
                    expect(response.status).to eq(401)
                end

                it "1ヶ月分の予定を取得(200)" do
                    get "/api/v1/calendar/#{year}/#{month}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)

                    expect(response.status).to eq(200)
                    # 以下でフォーマットを確認
                    expect(json["month"]).to eq(Date.parse("#{year}/#{month}").strftime("%Y-%m"))
                    expect(json["dates"].length).to eq(31)
                end
            end
        end
    end
end