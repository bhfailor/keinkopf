require 'test_helper'

class ConspectusControllerTest < ActionController::TestCase
  test "should get summarize" do
    get :summarize
    assert_response :success
  end

end
