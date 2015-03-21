require 'rails_helper'

feature 'Deauthentication', type: :feature do
  scenario 'User signs out via the navbar', :js do
    password = Faker::Internet.password
    user = create(:user, password: password, password_confirmation: password)

    # Given I am signed in
    sign_in_with_credentials user.email, password

    # When I sign out
    sign_out_via_navbar

    # Then I should see a signed out message
    expect(page).to have_selector '.alert-success', t('devise.sessions.signed_out')

    # And I should be signed out
    assert_signed_out
  end

  def sign_in_with_credentials(email, password)
    visit '/users/sign_in'
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    click_button 'Sign in'
  end

  def sign_out_via_navbar
    # Click on User Profile Name Dropdown
    within 'nav' do
      find('.navbar-right a.dropdown-toggle').click
    end

    # Select Logout from the dropdown menu
    within '.dropdown-menu' do
      click_link 'Logout'
    end
  end

  def assert_signed_out
    expect(page).to_not have_selector '.navbar-nav .user-name'
    expect(page).to have_selector ".navbar-nav a[href$='#{new_user_session_path}']", 'Login'
    expect(current_path).to eq new_user_session_path
  end
end
