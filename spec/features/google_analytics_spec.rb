require 'rails_helper'

feature 'Google Analytics', type: :feature do
  scenario 'the configured Google Analytics ID is included within the html element' do
    google_analytics_id = 'UA-XXXXX-X'
    allow(::Settings).to receive(:google_analytics_id).and_return(google_analytics_id)

    visit root_url
    expect(page).to have_xpath("//html[@data-google-analytics-id='#{google_analytics_id}']")
  end
end
