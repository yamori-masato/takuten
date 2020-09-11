require 'rails_helper'

RSpec.describe Onetime, type: :model do
    let(:t) { Time.parse("2000/01/01 12:00:00") }
    describe 'バリデーション' do
        describe 'date' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:onetime, date: nil)).not_to be_valid
                end
            end
        end
        describe 'time_start' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:onetime, time_start: nil)).not_to be_valid
                end
            end
        end
        describe 'time_end' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:onetime, time_start: nil)).not_to be_valid
                end
            end
        end
        context 'time_start < time_endの時' do
            it '登録できない' do
                expect(build(:onetime, time_start: t.since(1.hours), time_end: t)).not_to be_valid

            end
        end
        context 'time_start = time_endの時' do
            it '登録できない' do
                expect(build(:onetime, time_start: t, time_end: t)).not_to be_valid
            end
        end
        context 'time_start > time_endの時' do
            it '登録できる' do
                expect(build(:onetime, time_start: t, time_end: t.since(1.hours))).to be_valid
            end
        end
    end
end
