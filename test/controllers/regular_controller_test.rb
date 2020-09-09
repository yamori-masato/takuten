require 'test_helper'

class RegularControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get regular_index_url
    assert_response :success
  end

  test "should get create" do
    get regular_create_url
    assert_response :success
  end

  test "should get update" do
    get regular_update_url
    assert_response :success
  end

  test "should get destroy" do
    get regular_destroy_url
    assert_response :success
  end

end
