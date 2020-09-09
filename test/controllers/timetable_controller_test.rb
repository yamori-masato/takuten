require 'test_helper'

class TimetableControllerTest < ActionDispatch::IntegrationTest
  test "should get month" do
    get timetable_month_url
    assert_response :success
  end

  test "should get date" do
    get timetable_date_url
    assert_response :success
  end

end
