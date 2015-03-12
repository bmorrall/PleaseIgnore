require 'rails_helper'

feature 'Authentication via Email' do

  scenario 'sign in is disabled when user has no login password' do
    # Given there is a user without a login password
    user = create(:user, :no_login_password)

    # When I attempt to login without a password
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    click_button 'Sign in'

    # Then I should see an illegal password error
    expect(page).to have_selector '.alert-danger', t('devise.failure.invalid')
  end
end
