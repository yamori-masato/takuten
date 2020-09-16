class Api::V1::BandsController < ApplicationController
  # current_userが所属するバンドのコントロール
  before_action :set_current_users_band, only: [:show, :update, :leave]
  before_action :validate_user_ids, only: [:update]

  # GET /bands
  def index
    @bands = current_user.bands.all
    render json: @bands, each_serializer: BandSerializer
  end

  # GET /bands/1
  def show
    render json: @band, serializer: BandSerializer
  end


  # DELETE /bands/:id/leave
  # 指定したバンドから、自身が抜ける(ログインユーザ)
  def leave
    current_user.bands.destroy(@band)
    render plain: "successfully left '#{@band.name}'"
  end



  # PATCH/PUT /bands/1
  # アプリの仕様上、user_idsは変更前のものは消せない仕組み。 例) [1,2,3]->[2,3,4]としたら、勝手に[1,2,3,4](新旧の和集合)で登録する。
  def update
    old_ids = @band.user_ids
    bp = band_params.to_h
    bp[:user_ids] |= old_ids if band_params[:user_ids] #user_idsがリクエストパラメータに含まれる時、新旧の和集合で登録

    if @band.update(bp)
      render json: @band, serializer: BandSerializer
    else
      render json: @band.errors, status: :unprocessable_entity#422
    end
  end


  # POST /bands
  # (ログインユーザをメンバーに含めた)バンドを新規作成
  def create
    @band = Band.new(band_params)
    @band.user_ids = @band.user_ids.reject{|i| i == current_user.id} # 既にu1-b1が関連づけられている時に、u1.bands<<b1をするとそれぞれで関連がダブるから先に除外
    if @band.save
      current_user.bands << @band
      render json: @band, status: :created#201
    else
      render json: @band.errors, status: :unprocessable_entity#422
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_current_users_band
      @band = current_user.bands.find_by(id: params[:id])
      unless @band
        render plain: "Band(id: #{params[:id]}) is not found", status: :not_found#404
      end
    end

    # Only allow a trusted parameter "white list" through.
    def band_params
      params.permit(:name, {user_ids: []})
    end

    # user_idsに無効なidが含まれないかをチェック
    def validate_user_ids
      if band_params[:user_ids] && band_params[:user_ids].any? {|id| !User.find_by(id: id) }
        render plain: "'user_ids' is invalid", status: :unprocessable_entity#422
      end
    end
end
