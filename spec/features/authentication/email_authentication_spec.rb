require 'rails_helper'

feature 'Email Authentication', type: :feature do
  # Success

  scenario 'Guest signs in with correct credentials' do
    # Given there is a user with a login
    password = 'password123' || Faker::Internet.password
    user = create(:user, password: password, password_confirmation: password)

    # When I sign in with valid credentials
    sign_in_with_credentials user.email, password

    # Then I see a successful sign in message
    expect(page).to have_selector '.alert-success', t('devise.sessions.signed_in')

    # And I should be at the new registration path
    expect(current_path).to eq dashboard_path

    # And I should be signed in
    assert_signed_in user
  end

  # Failure

  scenario 'Guest attempts to sign in with non existant account' do
    # When I attempt to login with an incorrect password
    sign_in_with_credentials Faker::Internet.email, Faker::Internet.password

    # Then I should see an invalid password error
    expect(page).to have_selector '.alert-danger', t('devise.failure.invalid')

    # And I should not be signed in
    assert_signed_out
  end

  scenario 'Guest attempts to sign in with incorrect password' do
    # Given there is a user with a login
    user = create(:user)

    # When I attempt to login with an incorrect password
    sign_in_with_credentials user.email, Faker::Internet.password

    # Then I should see an invalid password error
    expect(page).to have_selector '.alert-danger', t('devise.failure.invalid')

    # And I should not be signed in
    assert_signed_out
  end

  scenario 'Guest with no login password attempts to sign in' do
    # Given there is a user without a login password
    user = create(:user, :no_login_password)

    # When I attempt to login without a password
    sign_in_with_credentials user.email

    # Then I should see an illegal password error
    expect(page).to have_selector '.alert-danger', t('devise.failure.invalid')

    # And I should not be signed in
    assert_signed_out
  end

  # WHEN

  def sign_in_with_credentials(email, password = nil)
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password if password
    click_button 'Sign in'
  end

  # THEN

  def assert_signed_in(user)
    expect(page).to have_selector '.navbar-nav .user-name', user.name
  end

  def assert_signed_out
    expect(page).to_not have_selector '.navbar-nav .user-name'
    expect(page).to have_selector(
      ".navbar-nav a[href$='#{new_user_session_path}']", t('layouts.navigation.my_dashboard')
    )
  end
end
