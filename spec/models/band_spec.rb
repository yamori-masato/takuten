require 'rails_helper'

RSpec.describe Band, type: :model do
    describe "バリデーション" do
        describe 'name' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:band, name: nil)).not_to be_valid
                end
            end
            describe '長さ' do
                context '30文字以内の時' do
                    it '正しい' do
                        expect(build(:band, name: 'a'*30)).to be_valid
                    end
                end
                context '30文字以上の時' do
                    it '正しくない' do
                        expect(build(:band, name: 'a'*31)).not_to be_valid
                    end
                end
            end
        end
    end

  
end
