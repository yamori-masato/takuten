require 'test_helper'

class UserBandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_band = user_bands(:one)
  end

  test "should get index" do
    get user_bands_url, as: :json
    assert_response :success
  end

  test "should create user_band" do
    assert_difference('UserBand.count') do
      post user_bands_url, params: { user_band: { band_id: @user_band.band_id, user_id: @user_band.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show user_band" do
    get user_band_url(@user_band), as: :json
    assert_response :success
  end

  test "should update user_band" do
    patch user_band_url(@user_band), params: { user_band: { band_id: @user_band.band_id, user_id: @user_band.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy user_band" do
    assert_difference('UserBand.count', -1) do
      delete user_band_url(@user_band), as: :json
    end

    assert_response 204
  end
end
