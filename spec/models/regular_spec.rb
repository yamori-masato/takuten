require 'rails_helper'

RSpec.describe Activity::Regular, type: :model do
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
            expect(build(:regular, band_id: nil)).not_to be_valid
        end
      end
    end

    describe "display_on_the_calendar" do
      describe "validate_time_should_fit_the_section" do
        context 'time_start,time_endが区分と一致しないとき' do
          it '登録できない' do
            expect(build(:regular, time_start: Time.parse("00:00:00"))).not_to be_valid
          end
        end
      end
    end

  end

  describe '#week' do
    let(:week) { build(:regular,date_start: date_start).week }
    subject { week }
    context "date_startが 2000-01-01 の時" do
      let(:st) {1}
      it '土曜日(6)' do
        expect(subject).to eq 6
      end
    end
    context "date_startが 2000-01-03 の時" do
      let(:st) {3}
      it '月曜日(1)' do
        expect(subject).to eq 1
      end
    end
  end

  describe '#occurs_between' do
    describe "「y-m-d」フォーマットのstring型のリストで、繰り返し日を返す" do
      let(:occurs_between) { build(:regular,date_start: date_start).occurs_between ost,oed }
      let(:st) {1}
      subject { occurs_between}
      describe 'start_date, end_date がそれぞれ' do
        context "2000-01-01, 2000-01-31 の時" do
          let(:ost) { Date.parse("2000/1/1") }
          let(:oed) { Date.parse("2000/1/31") }
          it {is_expected.to eq %w"2000-01-01 2000-01-08 2000-01-15 2000-01-22 2000-01-29"}
        end
        context "2000-01-02, 2000-01-15 の時" do
          let(:ost) { Date.parse("2000/1/2") }
          let(:oed) { Date.parse("2000/1/15") }
          it {is_expected.to eq %w"2000-01-08 2000-01-15"}
        end
        context "2000-01-10, 2000-01-14 の時" do
          let(:ost) { Date.parse("2000/1/10") }
          let(:oed) { Date.parse("2000/1/14") }
          it {is_expected.to be_empty}
        end
        context "2000-01-01, 2000-01-01 の時" do
          let(:ost) { Date.parse("2000/1/01") }
          let(:oed) { Date.parse("2000/1/01") }
          it {is_expected.to eq %w"2000-01-01"}
        end
      end
    end
  end

  describe 'Activity::Regular.between' do
    let(:between) { Activity::Regular.between(date_start, date_end, band_id:band_id) }
    subject { between.length }

    describe 'arg1,arg2 に対する取得件数の検証' do
      describe 'テストデータとして、date_start:2000-01-01 で登録(全5件)' do
        before do
          create(:regular)
        end
        let(:band_id) {nil}
        context '引数が (2020-01-01, 2020-01-31) の時' do
          let(:st) {1}
          let(:ed) {31}
          it {is_expected.to eq 5}
        end
        context '引数が (2020-01-01, 2020-01-15) の時' do
          let(:st) {1}
          let(:ed) {15}
          it {is_expected.to eq 3}
        end
        context '引数が (2020-01-05, 2020-01-12) の時' do
          let(:st) {5}
          let(:ed) {12}
          it {is_expected.to eq 1}
        end
      end
    end
    describe 'band_id引数を指定するとそのバンドのコマだけに絞られることの検証' do
      describe 'テストデータとして、2種類のバンドで date_start:2000-01-01 で登録する(全10件)' do
        before do
          2.times do |n|
            @band = Band.create(name: "band#{n}")
            create(:regular, band_id: @band.id)
          end
        end
      
        context '引数が (2020-01-01, 2020-01-31, band_id: 指定) の時' do
          let(:band_id) {@band.id}
          let(:st) {1}
          let(:ed) {31}
          it {is_expected.to eq 5}
        end
      end
    end
  end

  describe '#create_exception_if_already_booked' do
    describe 'インスタンス作成時に、繰り返しのどこかで既に予約が埋まっている日にちがあったら、例外日として登録する(ExceptionTimeのインスタンス作成)' do
      context '自身とは別のバンドによる予約が繰り返しに含まれる時'do
        context '2000-01-08 09:00~11:00 が、NonregularとRegularによって予約済みの時' do
          before do
            band = create(:band)
            create(:nonregular, date: Date.parse('2000-01-08'), band_id: band.id)
            band = create(:band)
            create(:regular, date_start: Date.parse('2000-01-08'), band_id: band.id)
          end
          it 'このコマを除外' do
            band = create(:band)
            regular = create(:regular, date_start: Date.parse('2000-01-01'), band_id: band.id)
            et = regular.exception_times
            expect(et.length).to eq 1
            expect(et.first.date).to eq Date.parse('2000-01-08')
          end
        end
        context '2000-01-08 09:00~11:00 が、2つのNonregularによって予約済みの時' do
          before do
            2.times{ create(:nonregular, date: Date.parse('2000-01-08')) }
          end
          it 'このコマを除外' do
            band = create(:band)
            regular = create(:regular, date_start: Date.parse('2000-01-01'), band_id: band.id)
            et = regular.exception_times
            expect(et.length).to eq 1
            expect(et.first.date).to eq Date.parse('2000-01-08')
          end
        end
        context '2000-01-08 09:00~11:00 が、1つのRegularによって予約済みの時' do
          before do
            create(:regular, date_start: Date.parse('2000-01-08'))
          end
          it '除外は作られない' do
            band = create(:band)
            regular = create(:regular, date_start: Date.parse('2000-01-01'), band_id: band.id)
            et = regular.exception_times
            expect(et.length).to eq 0
          end
        end
        context '2000-01-08 09:00~11:00 が、1つのNonregularによって予約済みの時' do
          before do
            create(:nonregular, date: Date.parse('2000-01-08'))
          end
          it '除外は作られない' do
            band = create(:band)
            regular = create(:regular, date_start: Date.parse('2000-01-01'), band_id: band.id)
            et = regular.exception_times
            expect(et.length).to eq 0
          end
        end
      end
      context '自身のバンドによる予約が繰り返しに含まれる時' do
        context '2000-01-08 09:00~11:00 が、Nonregularによって予約済みの時' do
          before do
            @band = create(:band)
            create(:nonregular, date: Date.parse('2000-01-08'), band_id: @band.id)
          end
          it 'このコマを除外' do
            regular = create(:regular, date_start: Date.parse('2000-01-01'), band_id: @band.id)
            et = regular.exception_times
            expect(et.length).to eq 1
            expect(et.first.date).to eq Date.parse('2000-01-08')
          end
        end
      end
    end
  end
end