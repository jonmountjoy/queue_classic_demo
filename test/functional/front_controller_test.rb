require 'test_helper'

class FrontControllerTest < ActionController::TestCase
  test "should get start" do
    get :start
    assert_response :success
  end

  test "should get check" do
    get :check
    assert_response :success
  end

end
