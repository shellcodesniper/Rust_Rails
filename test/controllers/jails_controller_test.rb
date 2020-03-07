require 'test_helper'

class JailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jail = jails(:one)
  end

  test "should get index" do
    get jails_url
    assert_response :success
  end

  test "should get new" do
    get new_jail_url
    assert_response :success
  end

  test "should create jail" do
    assert_difference('Jail.count') do
      post jails_url, params: { jail: { end_date: @jail.end_date, judger: @jail.judger, reason: @jail.reason, start_date: @jail.start_date, targetid: @jail.targetid, title: @jail.title, type: @jail.type } }
    end

    assert_redirected_to jail_url(Jail.last)
  end

  test "should show jail" do
    get jail_url(@jail)
    assert_response :success
  end

  test "should get edit" do
    get edit_jail_url(@jail)
    assert_response :success
  end

  test "should update jail" do
    patch jail_url(@jail), params: { jail: { end_date: @jail.end_date, judger: @jail.judger, reason: @jail.reason, start_date: @jail.start_date, targetid: @jail.targetid, title: @jail.title, type: @jail.type } }
    assert_redirected_to jail_url(@jail)
  end

  test "should destroy jail" do
    assert_difference('Jail.count', -1) do
      delete jail_url(@jail)
    end

    assert_redirected_to jails_url
  end
end
