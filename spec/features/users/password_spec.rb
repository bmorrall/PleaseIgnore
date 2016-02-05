require 'rails_helper'

feature 'User Password', type: :feature do
  scenario 'Add Login Password', :js, :omniauth, :login_facebook_user do
    # When I visit my password page
    visit_my_password_page

    # And I add login credentials to my account
    add_login_credentials_to_account

    # Then I should see a password created message
    assert_selector '.alert-success', text: t('devise.registrations.added_password')

    # And I should have added login credentials
    assert_login_credentials_updated login_credentials[:email]
  end

  scenario 'Update Password', :js, :login_user do
    # When I visit my password page
    visit_my_password_page

    # And I edit my password details
    update_login_credentials

    # Then I should see a password changed message
    assert_selector '.alert-success', text: t('devise.registrations.updated_password')

    # And I should have updatd my password
    assert_login_credentials_updated
  end

  scenario 'Update Password Regression', :js, :login_user do
    # When I visit my password page
    visit_my_password_page

    # And I submit invalid password details
    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'not_matching'
    fill_in 'user[current_password]', with: @logged_in_user.password
    click_button t('devise.registrations.edit.buttons.change_password')

    # Then I should see an error notification message
    assert_selector '.alert-danger', text: t('simple_form.error_notification.default_message')

    # And I should not see the profile form
    expect(page).to_not have_selector("input[name='user[name]']")

    # When I update my credentials
    update_login_credentials

    # And I should have updated my password
    assert_selector '.alert-success', text: t('devise.registrations.updated_password')
    assert_login_credentials_updated
  end

  def visit_my_password_page
    navigate_to_my_profile
    click_link t('layouts.navigation.my_password')
  end

  def add_login_credentials_to_account
    fill_in 'user[email]', with: login_credentials[:email]
    fill_in 'user[password]', with: login_credentials[:password]
    fill_in 'user[password_confirmation]', with: login_credentials[:password]
    click_button t('devise.registrations.edit.buttons.add_password')
  end

  def update_login_credentials
    fill_in 'user[password]', with: login_credentials[:password]
    fill_in 'user[password_confirmation]', with: login_credentials[:password]
    fill_in 'user[current_password]', with: @logged_in_user.password
    click_button t('devise.registrations.edit.buttons.change_password')
  end

  def assert_login_credentials_updated(email = nil)
    logged_in_user.reload
    expect(logged_in_user.email).to eq(email) if email
    expect(logged_in_user.valid_password?(login_credentials[:password])).to be(true)
  end

  def login_credentials
    @login_credentials ||=
      attributes_for(:user).select { |attribute| %i(email password).include? attribute }
  end
end
