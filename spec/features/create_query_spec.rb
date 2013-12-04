require 'spec_helper'
require 'pry'

feature "Query Management" do
  scenario "edits and updates a query" do
    expect(root_path).to eq('/')
    visit root_path
    expect(page).to_not have_content 'Show'
    expect(page).to_not have_content 'Back'
    #binding.pry
    expect(page).to have_css 'input [name="commit"] [value="update this query"] [type="submit"]'
    expect(page).to have_content 'Editing MLP Query'
    click_button 'update'
    expect(page).to have_content 'edit this query'
    expect(page).to have_content 'submit this query'
    save_and_open_page
    binding.pry
    four = 2+2
  end
  scenario "submits a query to obtain a table" do
  end
end
