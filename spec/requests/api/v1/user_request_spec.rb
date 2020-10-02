require "rails_helper"

RSpec.describe "Api::V1::User", type: :request do
    describe "UserAPI" do
        before do
            10.times{ create(:user) }
        end
        # letは遅延評価されるからそれぞれのブロックでuserが呼ばれた時の「User.first」が代入される
        # has_secure_passwordの影響で、直接Userオブジェクトは渡せない
        let(:user) { User.first }
        let(:user_params) { {name: user.name, password: "pass"} }

        describe "GET /api/v1/users" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/users"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "全てのユーザーを取得する(200)" do
                    get "/api/v1/users", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)
                
                    expect(response.status).to eq(200)
                    expect(json.length).to eq(10)
                end
            end
        end


        describe "GET /api/v1/user" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    get "/api/v1/user"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userの詳細を取得する(200)" do
                    get "/api/v1/user", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                    json = JSON.parse(response.body)
                    ex = UserSerializer.new(user).serializable_hash.stringify_keys
    
                    expect(response.status).to eq(200)
                    expect(json).to eq ex
                end
            end
        end


        describe "PATCH /api/v1/user" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    patch "/api/v1/user"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                it "認証Userの詳細を更新する(200)" do
                    patch "/api/v1/user", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: { nickname: "タロー" }
                    json = JSON.parse(response.body)
                    ex = UserSerializer.new(user).serializable_hash.stringify_keys
                    ex["nickname"] = "タロー"
    
                    expect(response.status).to eq(200)
                    expect(json).to eq ex                                    # responseの内容
                    expect(User.find_by(nickname: "タロー")).not_to be nil    # 更新されたか
                end

                it "nicknameプロパティ以外は変更できない" do
                    invalid_params = { id: 10000, name: "太郎", password: "new_password", grade: 10, band_ids: [100000,200000] }
                    patch "/api/v1/user", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: invalid_params.merge({ nickname: "タロー" })

                    json = JSON.parse(response.body)
                    updated_user = User.find_by(nickname: "タロー")
                    
                    expect(response.status).to eq(200)
                    invalid_params.each do |attr, v|
                        expect(updated_user[attr]).not_to be attr
                    end
                end

                context "パラメータ値が相応しくない時" do
                    it "更新できない(422)" do
                        invalid_params = { nickname: "a"*100 }
                        patch "/api/v1/user", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: invalid_params
                        expect(response.status).to eq(422)
                        expect(User.find_by(nickname: "a"*100)).to be nil    # 更新されない
                    end
                end

            end
        end
    end
end