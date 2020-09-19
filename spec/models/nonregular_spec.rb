require 'rails_helper'

RSpec.describe Activity::Nonregular, type: :model do
  let(:date_start) { Date.parse("2000/1/#{st}") }
  let(:date_end) { Date.parse("2000/1/#{ed}") }
  let(:sec) { [["09:00:00", "11:00:00"], ["11:00:00", "13:00:00"]].map{|s| s.map{|t| Time.parse(t)}} }
  before do
    Timetable.create(date_start:Date.parse("1000/1/1"), sections:sec)
  end

  describe "バリデーション" do
    describe "band_id" do
      context '未入力の時' do
        it '登録できない' do
          expect(build(:nonregular, band_id: nil)).not_to be_valid
        end
      end
    end
    
    describe 'validate_triple_booking' do
      context 'コマが既に2件予約されている時' do
        before do
          2.times do |n|
            @band = Band.create(name: "band#{n}")
            create(:nonregular, band_id: @band.id)
          end
        end
        it '登録できない' do
          expect(build(:nonregular)).not_to be_valid
        end
      end
    end

    describe 'validate_cannot_book_at_the_same_time' do
      context '既に同じバンドで予約している時(nonregular)' do
          before do
            @band = Band.create(name: "band1")
            create(:nonregular, band_id: @band.id)
          end
          it '登録できない' do
            expect(build(:nonregular, band_id: @band.id)).not_to be_valid
          end
      end
      context '既に同じバンドで予約している時(regular)' do
        before do
          @band = Band.create(name: "band1")
          create(:regular, band_id: @band.id)
        end
        it '登録できない' do
          expect(build(:nonregular, band_id: @band.id)).not_to be_valid
        end
      end
    end

    describe "display_on_the_calendar" do
      describe "validate_time_should_fit_the_section" do
        context 'time_start,time_endが区分と一致しないとき' do
          before do
            
          end
          it '登録できない' do
            expect(build(:nonregular, time_start: Time.parse("01:00:00"))).not_to be_valid
          end
        end
      end
    end
  end
  
  describe '#delete_all_subsequent_schedules' do
    describe "引数以降の予定をすべて削除" do
      before do
        @band0 = create(:band)
        @dummy = create(:nonregular, date: Date.parse('1999-12-01'), band_id: @band0.id) # ds<date -> 変更なし
        create(:nonregular, date: Date.parse('2000-01-01'), band_id: create(:band).id)          # ds=date -> 削除
        create(:nonregular, date: Date.parse('2000-01-31'), band_id: create(:band).id)          # date<ds -> 削除
      end 
      context "引数が2000-01-01の時" do
        let(:date) { Date.parse('2000-01-01') }
        before do
          Activity::Nonregular.delete_all_subsequent_schedules(date)
        end
        
        context "date_start<(引数) のとき" do
          it "変化なし" do
            regular0 = Activity::Nonregular.find_by(band_id: @band0.id)
            expect(regular0).to eq @dummy
          end
        end
        context "(引数)<=date_start のとき" do
          describe "レコードを削除する" do
            describe "よって、メソッド実行前後の総レコード数は3->1" do
              subject { Activity::Nonregular.all.length }
              it {is_expected.to eq 1}
            end
          end
        end

      end
    end
  end


  describe 'Activity::Nonregular.between' do
    let(:between) { Activity::Nonregular.between(date_start, date_end, band_id:band_id) }
    subject { between.length }

    describe 'arg1,arg2 に対する取得件数の検証' do
      describe 'テストデータとして、1種類のバンドで毎日登録する(全31件)' do
        before '毎日違うバンドで登録' do
          31.times{ create(:nonregular_allday_each_band) } 
        end
        let(:band_id) {nil}
        context '引数が (2020-01-01, 2020-01-31) の時' do
          let(:st) {1}
          let(:ed) {31}
          it {is_expected.to eq 31}
        end
        context '引数が (2020-01-01, 2020-01-15) の時' do
          let(:st) {1}
          let(:ed) {15}
          it {is_expected.to eq 15}
        end
        context '引数が (2020-01-05, 2020-01-12) の時' do
          let(:st) {5}
          let(:ed) {12}
          it {is_expected.to eq 8}
        end
      end
    end
    describe 'band_id引数を指定するとそのバンドのコマだけに絞られることの検証' do
      describe 'テストデータとして、2種類のバンドで毎日登録する(全62件)' do
        before do
          2.times do |n|
            @band = Band.create(name: "band#{n}")
            31.times{ create(:nonregular_allday, band_id: @band.id) }
          end
        end
      
        context '引数が (2020-01-01, 2020-01-31, band_id: 指定) の時' do
          let(:band_id) {@band.id}
          let(:st) {1}
          let(:ed) {31}
          it {is_expected.to eq 31}
        end
      end
    end
  end

end
