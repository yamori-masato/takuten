require 'rails_helper'

RSpec.describe ExceptionTime, type: :model do
    let(:sec) { [["09:00:00", "11:00:00"], ["11:00:00", "13:00:00"]].map{|s| s.map{|t| Time.parse(t)}} }
    before do
        Timetable.create(date_start:Date.parse("1000/1/1"), sections:sec)
    end

    describe "バリデーション" do
        describe 'date' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:exception_time, date: nil)).not_to be_valid
                end
            end
        end

        describe 'recurring_id' do
            context '未入力の時' do
                it '登録できない' do
                    expect(build(:exception_time, recurring_id: nil)).not_to be_valid
                end
            end
        end

        describe "validate_match_recurring_pattern" do
            describe "dateがRegularの繰り返し内に含まれるかを検証" do
                context "含まれる時" do
                    it "登録できる" do
                        regular = create(:regular)
                        et = build(:exception_time, date: regular.date_start+7.days, recurring_id: regular.id)
                        expect(et).to be_valid
                    end
                end

                context "含まれない時" do
                    it "登録できない" do
                        regular = create(:regular)
                        et = build(:exception_time, date: regular.date_start+1.days, recurring_id: regular.id)
                        expect(et).not_to be_valid
                    end
                end
            end
        end
        
    end
end