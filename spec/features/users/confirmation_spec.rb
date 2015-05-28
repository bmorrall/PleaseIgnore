require 'rails_helper'
require 'email_spec'

feature 'User Confirmation', type: :feature do
  include(EmailSpec::Helpers)
  include(EmailSpec::Matchers)

  scenario 'User confirms their email address', :login_user do
    # Confirm via Dashboard
    send_confirmation_request_via_dashboard
    assert_dashboard_widget_hidden

    # Confirmation Email
    click_on_received_confirmation_email
    assert_account_is_confirmed
  end

  # When I request an email confirmation
  def send_confirmation_request_via_dashboard
    click_link 'Home'

    within '.confirm-account' do
      click_button t('devise.confirmations.form.send')
    end

    expect(page).to have_selector '.alert.alert-success strong', t('devise.confirmations.confirmed')
  end

  # And I click the link on the received email
  def click_on_received_confirmation_email
    subject = t('devise.mailer.confirmation_instructions.subject')
    subject = "[#{t('application.name')} TEST] #{subject}"
    open_email(logged_in_user.email, with_subject: subject)
    click_first_link_in_email
  end

  # Then my account should be confirmed
  def assert_account_is_confirmed
    expect(page).to have_selector '.alert.alert-success strong', t('devise.confirmations.confirmed')

    logged_in_user.reload
    expect(logged_in_user).to be_confirmed_at
  end

  # Then the confirmation widget should be hidden
  def assert_dashboard_widget_hidden
    expect(page).to_not have_selector '.confirm-account'

    # Empty Dashboard Cell
    expect(page).to have_selector 'p', t('dashboard.empty.display.empty_message')
  end
end
