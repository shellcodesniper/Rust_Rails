require 'test_helper'

class ConsoleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get console_index_url
    assert_response :success
  end

end
