require 'spec_helper'
require 'pry'

feature "Unsorted or sorted by HW percent complete using real data" do
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
    fill_in 'mlp_query_mlp_login_email', with: ENV["MLP_LOGIN_EMAIL"]
    fill_in 'mlp_query_section', with: '72'
    fill_in 'mlp_query_session', with: 'A'    
    fill_in 'mlp_query_semester', with: 'SP14'
    click_button 'okay'
    click_link 'submit this query'
    expect(page).to have_css 'input [name="pswd"] [type="password"]'
    fill_in 'password:', with: ENV["MLP_PASSWORD"]
    click_button 'submit'
    expect(page).to have_content "Summary Table" # main title
    expect(page).to have_content Time.now.in_time_zone("Eastern Time (US & Canada)").to_s[0..12] # subtitle contains current datetime
    expect(page).to have_content /hw% name mte current assignment correct\b\/total days sincelogoff hours to go\b\(estimate\) email/
  end

  scenario "the table is initially sorted by increasing mte number" do
    # binding.pry
    expect(page).to have_content 'mte'
    mtevals = []
    all('tr > td:nth-child(3)').each {|r| mtevals << r.text }
    expect(mtevals).to eq mtevals.sort
    #save_and_open_page
  end

  scenario "but the table can be displayed, sorted by increasing hw percent completed" do
    # binding.pry
    expect(page).to have_content 'mte'
    expect(page).to have_link 'sort by hw percent completed'
    click_link 'sort by hw percent completed'
    hwpercent = []
    all('tr > td:nth-child(1)').each {|r| hwpercent << r.text.to_i }
    expect(hwpercent).to eq hwpercent.sort
    #save_and_open_page
  end

  scenario "and it can be sorted by increasing mte number again" do
    click_link 'sort by hw percent completed'
    expect(page).to have_link 'sort by mte (default)'
    click_link 'sort by mte (default)'
    mtevals = []
    all('tr > td:nth-child(3)').each {|r| mtevals << r.text.to_i }
    expect(mtevals).to eq mtevals.sort
  end

end
