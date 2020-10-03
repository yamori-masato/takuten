require "rails_helper"

RSpec.describe "Api::V1::Regular", type: :request do
    describe "RegularAPI" do
        let(:date) { Date.parse("2000/1/#{st}") }
        let(:sec) { [["09:00:00", "11:00:00"], ["11:00:00", "13:00:00"]].map{|s| s.map{|t| Time.parse(t)}} }

        let(:user) { User.first }
        let(:user_params) { {name: user.name, password: "pass"} }
        let(:band_id) { user.bands.first.id }
        let(:regular) { user.bands.first.regulars.first }
        before do
            Timetable.create(date_start:Date.parse("1000/1/1"), sections:sec)
            # u1 - b1,b2,b3
            u = create(:user)
            3.times { create(:band, user_ids: [u.id]) }
            create(:regular, band_id: band_id)
        end




        describe "POST /api/v1/bands/:id/regular/except" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    post "/api/v1/bands/#{band_id}/regular/except"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                let(:st) { 8 }

                it "認証Userが所属するバンドの正規コマで、特定の日のコマをOFFにする(201)" do
                    params = { date: date }
                    post "/api/v1/bands/#{band_id}/regular/except", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                    json = JSON.parse(response.body)
                    excep = ExceptionTime.find_by( date: date )
                    ex = JSON.parse(ExceptionTimeSerializer.new(excep).serializable_hash.to_json) # dateは、シリアライズされる(to_json)のタイミングでdate型から変換されるから
                    
                    expect(response.status).to eq(201)
                    expect(json).to eq(ex)
                end
            end

            # exception_timeのバリデーション「正規コマのループで有り得る日なら登録可」
            context "パラメータ値が相応しくない時" do
                it "更新できない(422)" do
                    invalid_params = { date: regular.date_start + 1.days }
                    post "/api/v1/bands/#{band_id}/regular/except", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: invalid_params
                    expect(response.status).to eq(422)
                    expect(regular.exception_times).to be_blank    # 更新されない
                end
            end


            context "存在しない:idを指定した場合" do
                context "バンド自体が存在しない場合" do
                    it "取得できない(404)" do
                        post "/api/v1/bands/#{99999}/regular/except", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                        expect(response.status).to eq(404) # バンド自体存在しない
                    end
                end
                context "バンドは存在するが、current_userが所属しないバンドの場合" do
                    it "取得できない(404)" do
                        b = create(:band)
                        post "/api/v1/bands/#{b.id}/regular/except", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                        expect(response.status).to eq(404) # バンド自体存在しない
                    end
                end
            end
        end

    end
end