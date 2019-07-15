require 'test_helper'

class BasepointsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get basepoints_new_url
    assert_response :success
  end

end
