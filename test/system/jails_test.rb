require "application_system_test_case"

class JailsTest < ApplicationSystemTestCase
  setup do
    @jail = jails(:one)
  end

  test "visiting the index" do
    visit jails_url
    assert_selector "h1", text: "Jails"
  end

  test "creating a Jail" do
    visit jails_url
    click_on "New Jail"

    fill_in "End date", with: @jail.end_date
    fill_in "Judger", with: @jail.judger
    fill_in "Reason", with: @jail.reason
    fill_in "Start date", with: @jail.start_date
    fill_in "Targetid", with: @jail.targetid
    fill_in "Title", with: @jail.title
    fill_in "Type", with: @jail.type
    click_on "Create Jail"

    assert_text "Jail was successfully created"
    click_on "Back"
  end

  test "updating a Jail" do
    visit jails_url
    click_on "Edit", match: :first

    fill_in "End date", with: @jail.end_date
    fill_in "Judger", with: @jail.judger
    fill_in "Reason", with: @jail.reason
    fill_in "Start date", with: @jail.start_date
    fill_in "Targetid", with: @jail.targetid
    fill_in "Title", with: @jail.title
    fill_in "Type", with: @jail.type
    click_on "Update Jail"

    assert_text "Jail was successfully updated"
    click_on "Back"
  end

  test "destroying a Jail" do
    visit jails_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Jail was successfully destroyed"
  end
end
