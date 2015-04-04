require 'rails_helper'

feature 'User Dashboard', type: :feature do
  scenario 'Default Dashboard for User', :user do
    # Given I am signed in as a user
    login_user

    # When I view my account history
    within 'aside.sidenav' do
      click_link t('layouts.navigation.my_dashboard')
    end

    # Then I should see the empty Dashboard message
    expect(page).to have_content t('dashboard.empty.display.empty_message')
  end
end
