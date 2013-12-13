require 'spec_helper'
require 'pry'

feature "Query Management" do
  background do
    expect(root_path).to eq('/')
    visit root_path
    expect(page).to_not have_content 'Show'
    expect(page).to_not have_content 'Back'
    expect(page).to have_css 'input [name="commit"] [value="okay"] [type="submit"]'
    within 'h2' do
      expect(page).to have_content 'MLP Query Input'
    end
    expect(page).to have_content 'Welcome - please change parameters as needed for your query!'
  end

  scenario "edits and updates a query" do
    original_semester = find('input [id="mlp_query_semester"]').value
    fill_in 'mlp_query_semester', with: 'Foo'
    click_button 'okay'
    expect(page).to have_content 'Foo'
    expect(page).to_not have_content "#{original_semester}"
    expect(page).to have_content 'edit this query'
    expect(page).to have_content 'submit this query'
    # save_and_open_page
  end

  scenario "handles a Selenium::WebDriver::Error::TimeoutOutError", focus: true do
    Selenium::WebDriver::Wait.any_instance.stub(:until).and_raise(Selenium::WebDriver::Error::TimeOutError)
    click_button 'okay'
    click_link 'submit this query'
    expect(page).to have_css 'input [name="pswd"] [type="password"]'
    fill_in 'password:', with: 'anything'
    click_button 'submit'
    expect(page).to have_content "the MLP database query timed out - you may succeed if you try again"
  end

  scenario "handles invalid credentials" do
    click_button 'okay'
    click_link 'submit this query'
    expect(page).to have_css 'input [name="pswd"] [type="password"]'
    fill_in 'password:', with: 'bogus'
    click_button 'submit'
    expect(page).to have_content "login failed - please confirm MLP login email and password"
  end

  scenario "handles a query that returns no results", focus: false do
    fill_in 'mlp_query_mlp_login_email', with: ENV["MLP_LOGIN_EMAIL"]
    fill_in 'mlp_query_semester', with: 'BOGUS'
    click_button 'okay'
    click_link 'submit this query'
    fill_in "password", with: ENV["MLP_PASSWORD"]
    click_button 'submit'
    expect(page).to have_content 'no mte matches - please confirm semester, section, and session'
  end

  scenario "submits a query with password 'example'", focus: false do
    click_button 'okay'
    click_link 'submit this query'
    expect(page).to have_css 'input [name="pswd"] [type="password"]'
    fill_in 'password:', with: 'example'
    click_button 'submit'
    expect(page).to have_content "Summary Table" # main title
    expect(page).to have_content Time.now.in_time_zone("Eastern Time (US & Canada)").to_s[0..12] # subtitle contains current datetime
    expect(page).to have_content /hw% name mte current assignment correct\b\/total days sincelogoff hours to go\b\(estimate\) email/

  end
  # scenario "returns results for valid credentials and valid query parameters" # not needed => view is same as for password: "example"
end
