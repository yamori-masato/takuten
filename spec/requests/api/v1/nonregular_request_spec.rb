require "rails_helper"

RSpec.describe "Api::V1::Nonregular", type: :request do
    describe "NonregularAPI" do
        let(:date) { Date.parse("2000/1/#{st}") }
        let(:sec) { [["09:00:00", "11:00:00"], ["11:00:00", "13:00:00"]].map{|s| s.map{|t| Time.parse(t)}} }

        let(:user) { User.first }
        let(:user_params) { {name: user.name, password: "pass"} }
        let(:band_id) { user.bands.first.id }
        before do
            Timetable.create(date_start:Date.parse("1000/1/1"), sections:sec)
            # u1 - b1,b2,b3
            u = create(:user)
            create(:band, user_ids: [u.id])
        end
    


        describe "POST /api/v1/bands/:band_id/nonregulars" do
            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    post "/api/v1/bands/#{band_id}/nonregulars"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                describe "認証Userが所属するバンドでコマを予約する" do
                    let(:st) { 1 }
                    let(:params) { {date: date}.merge(time) }



                    context "time_start, time_end で開始(終了)時間を指定する時" do
                        context "パラメータ値が正しい時" do
                            let(:time) { {time_start: Time.parse("09:00:00"), time_end: Time.parse("11:00:00")} }
                            it "予約できる(201)" do
                                post "/api/v1/bands/#{band_id}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                                json = JSON.parse(response.body)
                                nonregular = Activity::Nonregular.find_by(date: date)
                                expect(nonregular).not_to be nil # 確かに新規作成されている
                                ex = JSON.parse(NonregularSerializer.new(nonregular).serializable_hash.to_json) # dateは、シリアライズされる(to_json)のタイミングでdate型から変換されるから
                                expect(response.status).to eq(201)
                                expect(json).to eq(ex)
                            end
                        end
                        context "パラメータ値が相応しくない時" do
                            let(:time) { {time_start: Time.parse("11:00:00"), time_end: Time.parse("09:00:00")} }
                            it "予約できない(422)" do
                                post "/api/v1/bands/#{band_id}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                                json = JSON.parse(response.body)

                                expect(response.status).to eq(422)
                            end
                        end
                    end

                    context "index で開始(終了)時間を指定する時" do
                        context "パラメータ値が正しい時" do
                            let(:time) { {index: 0} }
                            it "予約できる(201)" do
                                post "/api/v1/bands/#{band_id}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                                json = JSON.parse(response.body)
                                nonregular = Activity::Nonregular.find_by(date: date)
                                expect(nonregular).not_to be nil # 確かに新規作成されている
                                ex = JSON.parse(NonregularSerializer.new(nonregular).serializable_hash.to_json) # dateは、シリアライズされる(to_json)のタイミングでdate型から変換されるから
                                expect(response.status).to eq(201)
                                expect(json).to eq(ex)
                            end
                        end
                        context "パラメータ値が相応しくない時" do
                            let(:time) { {index: 100} }
                            it "予約できない(422)" do
                                post "/api/v1/bands/#{band_id}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}, params: params
                                expect(response.status).to eq(422)
                            end
                        end
                    end
                end


                context "存在しない:idを指定した場合" do
                    context "バンド自体が存在しない場合" do
                        it "取得できない(404)" do
                            post "/api/v1/bands/#{99999}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンド自体存在しない
                        end
                    end
                    context "バンドは存在するが、current_userが所属しないバンドの場合" do
                        it "取得できない(404)" do
                            b = create(:band)
                            post "/api/v1/bands/#{b.id}/nonregulars", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                            expect(response.status).to eq(404) # バンドは存在する
                        end
                    end
                end



            end
        end

        


        describe "DELETE /api/v1/bands/:band_id/nonregulars/:id" do
            before do
                create(:nonregular, band_id: band_id)
            end
            let(:id) { Band.find(band_id).nonregulars.first.id }


            context "アクセスtokenを含まない時" do
                it "認証失敗(401)" do
                    delete "/api/v1/bands/#{band_id}/nonregulars/#{id}"
                    expect(response.status).to eq(401)
                end
            end
            context "アクセスtokenを含む時" do
                describe "認証Userが所属するバンドのコマを削除する" do
                    it "削除できる(200)" do
                        delete "/api/v1/bands/#{band_id}/nonregulars/#{id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                        nonregular = Activity::Nonregular.find_by(id: id)
                        expect(nonregular).to be nil # 確かに削除されている
                        expect(response.status).to eq(200)
                    end

                    context "存在しない:idを指定した場合" do
                        context ":band_idが正しくない" do
                            context "バンド自体が存在しない場合" do
                                it "取得できない(404)" do
                                    delete "/api/v1/bands/#{99999}/nonregulars/#{1}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                                    expect(response.status).to eq(404) # バンド自体存在しない
                                end
                            end
                            context "バンドは存在するが、current_userが所属しないバンドの場合" do
                                it "取得できない(404)" do
                                    b = create(:band)
                                    delete "/api/v1/bands/#{b.id}/nonregulars/#{1}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                                    expect(response.status).to eq(404) # バンドは存在する
                                end
                            end
                        end
                        context ":band_idは正しいが:idが正しくない" do
                            context "非正規コマ自体が存在しない場合" do
                                it "取得できない(404)" do
                                    delete "/api/v1/bands/#{band_id}/nonregulars/#{99999}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                                    expect(response.status).to eq(404) # 非正規コマ自体存在しない
                                end
                            end
                            context "非正規コマは存在するが、current_userが所属しない非正規コマの場合" do
                                it "取得できない(404)" do
                                    n = create(:nonregular)
                                    delete "/api/v1/bands/#{band_id}/nonregulars/#{n.id}", headers: {HTTP_AUTHORIZATION: "Bearer #{sign_in(user_params)}"}
                                    expect(response.status).to eq(404) # 非正規コマは存在する
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end