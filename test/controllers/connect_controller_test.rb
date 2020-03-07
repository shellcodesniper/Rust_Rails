require 'test_helper'

class ConnectControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get connect_index_url
    assert_response :success
  end

end
