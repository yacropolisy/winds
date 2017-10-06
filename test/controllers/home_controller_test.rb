require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get st" do
    get home_st_url
    assert_response :success
  end

end
