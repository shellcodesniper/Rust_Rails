require 'test_helper'

class MessagelogControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get messagelog_update_url
    assert_response :success
  end

end
