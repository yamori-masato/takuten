class Api::V1::Admin::RegularController < ApplicationController
    before_action :set_band


    def create
        if @band.has_regular
            render plain: "#{@band.name} already has a regular"
        else
            @regular = @band.regulars.build(regular_params)
            if @regular.save!
                @band.update(has_regular: true)
                render json: @regular, status: :created #201
            else
                render json: @regular.errors, status: :unprocessable_entity #422
            end
        end
    end

    # 時間変更含む全ての正規コマを削除し、has_regular=falseにする
    def destroy
        unless @band.has_regular
            render plain: "#{@band.name} has no regular"
        else
            @band.regulars.each{|r| r.destroy}
            @band.update(has_regular: true)
            render plain: "successfully deleted #{@band.name}'s regular"
        end

    end

    # 時間変更(timetableの作成、regularの削除->regularの作成)
    def change
        unless @band.has_regular
            render plain: "#{@band.name} has no regular"
        else
            
        end
    end



    private
        def set_band
            @band = Band.find(params[:id])
        end
        
        def regular_params
            params.permit(:date_start, :time_start, :time_end)
        end
end

# time_start, time_end => timetableと照合してエラーチェック
# time_id => time_start,time_endに変換して登録