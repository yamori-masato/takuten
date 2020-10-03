require "rails_helper"

RSpec.describe "Api::V1::Band", type: :request do
    describe "BandAPI" do
        before do
            # u1 - b1,b2,b3  |  u2  |  u3
            u = create(:user)
            3.times { create(:band, user_ids: [u.id]) }

            2.times { create(:user) }
        end
        let(:user) { User.first }
        let(:user_params) { {name: user.name, password: "pass"} }
        let(:band_id) { user.bands.first.id }
    


        describe "GET /api/v1/bands" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/bands"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userが所属する全てのバンドを取得する(200)" do
                    get "/api/v1/bands", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)

                    expect(response.status).to eq(200)
                    expect(json.length).to eq(3)
                end
            end
        end

        describe "POST /api/v1/bands" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    post "/api/v1/bands", params: { name: "new", user_ids: [user.id, user.id+1, user.id+2] }
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userが所属するバンドを新規作成する(201)" do
                    post "/api/v1/bands", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: { name: "new", user_ids: [user.id, user.id+1, user.id+2] }
                    json = JSON.parse(response.body)
                    band = Band.find_by(name: "new")
                    expect(band).not_to be nil # 確かに新規作成されている
                    ex = BandSerializer.new(band).serializable_hash.stringify_keys

                    expect(response.status).to eq(201)
                    expect(json).to eq(ex)
                end

                it "user_idsパラメータにcurrent_userが含まれていなくても自動的に含まれる" do
                    post "/api/v1/bands", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: { name: "new", user_ids: [user.id+1, user.id+2] }
                    json = JSON.parse(response.body)
                    band = Band.find_by(name: "new")
                    ex = BandSerializer.new(band).serializable_hash.stringify_keys

                    expect(band.user_ids.sort).to eq [user.id, user.id+1, user.id+2]
                    expect(json).to eq(ex)
                end

                context "パラメータ値が相応しくない時" do
                    it "更新できない(422)" do
                        invalid_params = { name: "a"*100, user_ids: [100000] }
                        post "/api/v1/bands", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: invalid_params
                        expect(response.status).to eq(422)
                        expect(User.find_by(name: "a"*100)).to be nil    # 更新されない
                    end
                end
            end
        end

        describe "GET /api/v1/bands/:id" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/bands/#{band_id}"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userが所属するバンドを取得する(200)" do
                    get "/api/v1/bands/#{band_id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)
                    band = user.bands.find(band_id)
                    ex = BandSerializer.new(band).serializable_hash.stringify_keys

                    expect(response.status).to eq(200)
                    expect(json).to eq(ex)
                end
                context "存在しない:idを指定した場合" do
                    context "バンド自体が存在しない場合" do
                        it "取得できない(404)" do
                            get "/api/v1/bands/#{99999}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンド自体存在しない
                        end
                    end
                    context "バンドは存在するが、current_userが所属しないバンドの場合" do
                        it "取得できない(404)" do
                            b = create(:band)
                            get "/api/v1/bands/#{b.id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンド自体存在しない
                        end
                    end
                end
            end
        end

        describe "PATCH /api/v1/bands/:id" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    patch "/api/v1/bands/#{band_id}"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                describe "認証Userが所属するバンドの詳細を更新する(200)" do
                    it "nameを変更する" do
                        params = { name: "updated" }
                        patch "/api/v1/bands/#{band_id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                        json = JSON.parse(response.body)
                        band = Band.find_by(name: "updated")
                        expect(band).not_to be nil # 確かに更新されている
                        ex = BandSerializer.new(band).serializable_hash.stringify_keys

                        expect(response.status).to eq(200)
                        expect(json).to eq(ex)
                    end

                    describe "user_idsを変更する" do
                        it "user_idsは既存値とリクエスト値の和集合が登録される" do
                            params = { user_ids: [user.id+1, user.id+2] }
                            patch "/api/v1/bands/#{band_id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                            json = JSON.parse(response.body)
                            band = Band.find(band_id)
                            ex = BandSerializer.new(band).serializable_hash.stringify_keys

                            expect(response.status).to eq(200)
                            expect(json).to eq(ex)
                            expect(band.user_ids).to eq([user.id, user.id+1, user.id+2])
                        end
                    end
                end
                context "パラメータ値が相応しくない時" do
                    it "更新できない(422)" do
                        invalid_params = { name: "a"*100 }
                        patch "/api/v1/bands/#{band_id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: invalid_params
                        expect(response.status).to eq(422)
                        expect(User.find_by(name: "a"*100)).to be nil    # 更新されない
                    end
                end

                context "存在しない:idを指定した場合" do
                    context "バンド自体が存在しない場合" do
                        it "取得できない(404)" do
                            get "/api/v1/bands/#{99999}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンド自体存在しない
                        end
                    end
                    context "バンドは存在するが、current_userが所属しないバンドの場合" do
                        it "取得できない(404)" do
                            b = create(:band)
                            patch "/api/v1/bands/#{b.id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンド自体存在しない
                        end
                    end
                end
            end
        end

        describe "DELETE /api/v1/bands/:id/leave" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    delete "/api/v1/bands/#{band_id}/leave"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userが所属するバンドから脱退する(200)" do
                    delete "/api/v1/bands/#{band_id}/leave", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    band = Band.find(band_id)

                    expect(response.status).to eq(200)
                    expect(band.user_ids).not_to be_include(user.id)
                end
            end
            context "存在しない:idを指定した場合" do
                context "バンド自体が存在しない場合" do
                    it "取得できない(404)" do
                        delete "/api/v1/bands/#{99999}/leave", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                        expect(response.status).to eq(404) # バンド自体存在しない
                    end
                end
                context "バンドは存在するが、current_userが所属しないバンドの場合" do
                    it "取得できない(404)" do
                        b = create(:band)
                        delete "/api/v1/bands/#{b.id}/leave", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                        expect(response.status).to eq(404) # バンド自体存在しない
                    end
                end
            end
        end



    end
end