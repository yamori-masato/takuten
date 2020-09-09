
class Api::V1::BandsController < ApplicationController
  # current_userが所属するバンドのコントロール
  before_action :set_current_users_band, only: [:show, :update, :leave]

  # GET /bands
  def index
    @bands = current_user.bands.all
    render json: @bands, each_serializer: BandSerializer
  end

  # GET /bands/1
  def show
    render json: @band, serializer: BandSerializer
  end


  # PATCH /bands/:id/leave
  # 指定したバンドから、自身が抜ける(ログインユーザ)
  def leave
    current_user.bands.destroy(@band)
    render plain: "successfully left '#{@band.name}'"
  end



  # PATCH/PUT /bands/1
  def update
    #user_idsのバリデーション(あとでmodel層に引越し)-------------------------------------
    #excは、(nil: user_idsが送られなかった時)([]: user_idsが正常な値の時)([1,3]: user_idsが不正な値の時)
    exc = band_params[:user_ids]&.reject do |user_id|
      User.find_by(id: user_id)
    end
    if exc && (not exc.empty?)
      render plain: "user_ids: #{exc} is invalid", status: :unprocessable_entity
      return
    end
    #----------------------------------------------------------

    if @band.update(band_params)
      render json: @band, serializer: BandSerializer
    else
      render json: @band.errors, status: :unprocessable_entity
    end
  end


  # POST /bands
  # (ログインユーザをメンバーに含めた)バンドを新規作成
  def create
    @band = Band.new(band_params)
    if @band.save
      current_user.bands << @band
      render json: @band, status: :created#201
    else
      render json: @band.errors, status: :unprocessable_entity#422
    end
  end




  # # DELETE /bands/1
  # def destroy
  #   @band.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_current_users_band
      @band = current_user.bands.find(params[:id])
      # 見つからなかったらエラー吐くようにする
    end

    # Only allow a trusted parameter "white list" through.
    def band_params
      params.permit(:name, {user_ids: []})
    end

end
