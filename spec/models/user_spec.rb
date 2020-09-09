require 'rails_helper'

RSpec.describe User, type: :model do
    let(:user) { build(:user) }

    describe 'バリデーション' do
        describe 'name' do
            context '未入力の時' do
                it '登録できない'
            end
            describe '長さ' do
                context '15文字以内の時' do
                    it '正しい'
                end
                context '16文字以上の時' do
                    it '正しくない'
                end
            end
            context '重複するとき' do
                it '一意性が機能する'
            end
        end

        describe 'nickname' do  
            context '未入力の時' do
                it 'nameと同じ値にする'
            end
            describe '長さ' do
                context '15文字以内' do
                    it '正しい'
                end
                context '16文字以上' do
                    it '正しくない'
                end
            end
        end

        
    end

end
