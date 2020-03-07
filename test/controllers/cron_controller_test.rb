require 'test_helper'

class CronControllerTest < ActionDispatch::IntegrationTest
  test "should get cron_job" do
    get cron_cron_job_url
    assert_response :success
  end

end
