require 'test_helper'

class SeelogControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get seelog_index_url
    assert_response :success
  end

end
