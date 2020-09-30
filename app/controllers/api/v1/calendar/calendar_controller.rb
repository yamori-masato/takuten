class Api::V1::Calendar::CalendarController < ApplicationController
  # {date: time_st: time_ed: }のような、静的なカラムを持てない(recurringは期間から変換されるから)
  # だからポリモーフィック関連がつかえない？
  # 使うとカレンダーインターフェースからの処理が簡潔。でも、displayablesテーブルにはidがテーブルが保存されるだけで冗長な気もする
  # 関連使うとインスタンスごとの操作になるからrecurringテーブルとの相性が悪い。検索(期間指定)のロジックが子クラスごとでかなり違うからそれぞれのクラスにまかせたい(インスタンス単位だと厳しい)。

  # 理想はCalendarインターフェースからCRUDを使う(apiユーザからは子クラスの違いを意識しない)ことだが、現状解決法がわからない為
  # 今回は、「Calendarは見る専用のインターフェース」とし、CRUDは各子クラスをエンドポイントに指定してもらう

  
  #月単位
  def month
      date = Date.new(params[:year].to_i, params[:month].to_i, 1)#月初め
      @calendar = ::Calendar.new.one_month_occurrences(date)
      render json: @calendar, status: :ok
  end

  #日にち単位
  def date
      date = Date.new(params[:year].to_i, params[:month].to_i, params[:date].to_i)
      @calendar = ::Calendar.new(current_user: current_user)
      occurrences = calendar.one_day_occurrences(date)
      render json: @calendar.renderer(occurrences, date)
  end


end
