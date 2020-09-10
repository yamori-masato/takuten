require 'rails_helper'

RSpec.describe User, type: :model do
    # let(:user) { build(:user) }

    describe 'バリデーション' do
        describe 'name' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:user, name: nil)).not_to be_valid
                end
            end
            describe '長さ' do
                context '15文字以内の時' do
                    it '正しい' do
                        expect(build(:user, name: 'a'*15)).to be_valid
                    end
                end
                context '16文字以上の時' do
                    it '正しくない' do
                        expect(build(:user, name: 'a'*16)).not_to be_valid
                    end
                end
            end
            context '重複するとき' do
                it '一意性が機能する' do
                    create(:user, name: 'たかし')
                    expect(build(:user, name: 'たかし')).not_to be_valid
                end
            end
        end

        describe 'nickname' do  
            context '未入力の時' do
                it 'nameと同じ値になる' do
                    user = create(:user, nickname: nil)
                    expect(user.nickname).to eq user.name
                end
            end
            describe '長さ' do
                context '15文字以内' do
                    it '正しい' do
                        expect(build(:user, nickname: '123456789012345')).to be_valid
                    end
                end
                context '16文字以上' do
                    it '正しくない' do
                        expect(build(:user, nickname: '123456789012345')).to be_valid
                    end
                end
            end
        end
    end
end
