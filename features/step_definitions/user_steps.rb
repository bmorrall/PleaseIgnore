### UTILITY METHODS ###

def destroy_session
  Capybara.reset_sessions!
  @current_page = nil
  # page.driver.submit :delete, "/users/sign_out", {}
end

def create_visitor
  @visitor ||= begin
    visitor_attributes = attributes_for(:user)
    {
      name: visitor_attributes[:name],
      email: visitor_attributes[:email],
      password: 'changeme',
      password_confirmation: 'changeme'
    }
  end
end

def find_user
  @user ||= User.where(email: create_visitor[:email]).first
end

def create_unconfirmed_user
  create_visitor
  delete_user
  submit_registration
  destroy_session
end

def create_user
  delete_user
  @user = create(:user, create_visitor)
end

def delete_user
  @user ||= find_user
  @user.destroy unless @user.nil?
  @visitor = nil
end

def fill_in_registration(skip_password = false)
  create_visitor
  fill_in 'user_name', with: @visitor[:name]
  fill_in 'user_email', with: @visitor[:email]
  unless skip_password
    fill_in 'user_password', with: @visitor[:password]
    fill_in 'user_password_confirmation', with: @visitor[:password_confirmation]
  end
  check 'user_terms_and_conditions'
end

def submit_registration(skip_password = false)
  navigate_to 'the sign up page'
  fill_in_registration(skip_password)
  click_button 'Sign up'
  find_user
end

def sign_in
  create_visitor

  navigate_to 'the sign in page'
  fill_in 'user_email', with: @visitor[:email]
  fill_in 'user_password', with: @visitor[:password]
  click_button 'Sign in'
end

def reset_password
  create_visitor

  navigate_to 'the reset password page'
  fill_in 'user_email', with: @visitor[:email]
  click_button 'Reset Password'

  page.body # No-op as background operation may not be complete
end

def visit_my_profile
  within 'nav.navbar' do
    click_link t('layouts.navigation.my_dashboard')
  end if page.has_selector?('nav.navbar a', text: t('layouts.navigation.my_dashboard'))

  unless Capybara.current_session.server.nil?
    # User must click name to trigger js dropdown menu
    click_link @visitor[:name]
  end
  within 'nav.navbar' do
    click_link t('layouts.navigation.my_profile')
  end
end

### GIVEN ###
Given(/^I am not logged in$/) do
  destroy_session
end

Given(/^I am logged in$/) do
  @user || create_user
  sign_in
end

Given(/^I exist as a user$/) do
  create_user
end

Given(/^I do not exist as a user$/) do
  create_visitor
  delete_user
end

Given(/^I exist as an unconfirmed user$/) do
  create_unconfirmed_user
end

Given(/^I have made a password reset request$/) do
  reset_password
end

When(/^I sign up with valid user data$/) do
  create_visitor
  submit_registration
end

When(/^I complete the registration form$/) do
  create_visitor
  submit_registration(true)
end

When(/^I sign up with an invalid email$/) do
  create_visitor
  @visitor = @visitor.merge(email: 'notanemail')
  submit_registration
end

When(/^I sign up without a password confirmation$/) do
  create_visitor
  @visitor = @visitor.merge(password_confirmation: '')
  submit_registration
end

When(/^I sign up without a password$/) do
  create_visitor
  @visitor = @visitor.merge(password: '')
  submit_registration
end

When(/^I sign up with a mismatched password confirmation$/) do
  create_visitor
  @visitor = @visitor.merge(password_confirmation: 'changeme123')
  submit_registration
end

When(/^I return to the site$/) do
  navigate_to 'the home page'
end

When(/^I edit my account details$/) do
  visit_my_profile
  fill_in 'user_name', with: 'newname'
  click_button 'Update'
end

When(/^I edit my password details$/) do
  visit_my_profile
  fill_in 'user_password', with: 'newpassword1'
  fill_in 'user_password_confirmation', with: 'newpassword1'
  fill_in 'user_current_password', with: @visitor[:password]
  click_button 'Change Password'
end

When(/^I look at the list of users$/) do
  pending 'TODO: Display list of users'
end

When(/^I enter a valid password reset request$/) do
  reset_password
end

When(/^I enter valid password reset details$/) do
  fill_in 'user_password', with: @visitor[:password]
  fill_in 'user_password_confirmation', with: @visitor[:password]
  click_button 'Change my password'
end

When(/^I enter mismatched password reset confirmation$/) do
  fill_in 'user_password', with: @visitor[:password]
  fill_in 'user_password_confirmation', with: 'changeme123'
  click_button 'Change my password'
end

### THEN ###
Then(/^I should be signed in$/) do
  page.has_selector?('li', text: 'Logout', visible: false)
end

Then(/^I should be signed out$/) do
  # Home -> Login Page
  within 'nav.navbar' do
    click_link t('layouts.navigation.my_dashboard')
  end

  # Login page is only visible when user is not signed in
  page.has_no_selector?('li', text: 'Logout', visible: false)
end

Then(/^I see an unconfirmed account message$/) do
  expect(page).to have_content 'You have to confirm your account before continuing.'
end

Then(/^I should see a successful sign up message$/) do
  expect(page).to have_content 'Welcome! You have signed up successfully.'
end

Then(/^I should see an invalid email message$/) do
  expect(page).to have_content 'Email is invalid'
end

Then(/^I should see a missing password message$/) do
  expect(page).to have_content "Password can't be blank"
end

Then(/^I should see a missing password confirmation message$/) do
  expect(page).to have_content "Password confirmation doesn't match"
end

Then(/^I should see a mismatched password message$/) do
  expect(page).to have_content "Password confirmation doesn't match"
end

Then(/^I should see an account edited message$/) do
  expect(page).to have_content t('devise.registrations.updated')
end

Then(/^I should see a password changed message$/) do
  expect(page).to have_content t('devise.registrations.updated_password')
end

Then(/^I should see my name$/) do
  create_user
  expect(page).to have_content @user[:name]
end

Then(/^I should see a password reset email has been sent notice$/) do
  expect(page).to have_content(
    'If your email address exists in our database, '\
    'you will receive a password recovery link at your email address in a few minutes.'
  )
end

Then(/^I should see a password was reset message$/) do
  expect(page).to have_content 'Your password was changed successfully'
end

Then(/^(?:I|they) should receive an email with Reset password instructions$/) do
  expect(unread_emails_for(@visitor[:email]).size).to eq(1)

  # this call will store the email and you can access it with current_email
  open_last_email_for(@visitor[:email])
  expect(current_email).to have_subject(/Reset password instructions/)
  expect(current_email).to be_delivered_from('accounts@pleaseignore.com')

  expect(current_email).to have_body_text(@visitor[:name])
  expect(current_email).to have_link('Change my password')
end
