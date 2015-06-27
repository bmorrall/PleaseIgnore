
def create_contact_request
  @contact_request ||= {
    name: 'Example User',
    email: 'user@example.com',
    body: 'I am making a contact request'
  }
end

def begin_contact_request
  within 'nav.navbar' do
    click_link t('layouts.navbar_items.contact')
  end
end

def fill_in_and_send_contact_request
  create_contact_request
  fill_in 'contact_name', with: @contact_request[:name]
  fill_in 'contact_email', with: @contact_request[:email]
  fill_in 'contact_body', with: @contact_request[:body]
  click_button 'Send'
end

### GIVEN

Given(/^A visitor has sent a contact request from (.*)$/) do |page_name|
  visit path_to(page_name)

  # Send the contact request
  begin_contact_request
  fill_in_and_send_contact_request

  # Sign out
  destroy_session
end

### WHEN

When(/^I send a contact request$/) do
  begin_contact_request
  fill_in_and_send_contact_request
end

When(/^I begin a new contact request$/) do
  begin_contact_request
end

When(/^I submit an incomplete contact request$/) do
  begin_contact_request
  click_button 'Send'
end

### THEN

Then(/^I should be notified I am making a request from (.+)$/) do |page_name|
  referer_path = "#{current_host_with_port}#{path_to(page_name)}"
  expect(page).to have_selector(
    '.alert.alert-info', t('flash.contacts.show.info', referer: referer_path)
  )
end

Then(/^I should see a thank you message$/) do
  expect(page).to have_selector(
    '.alert.alert-success', text: t('flash.contacts.create.notice')
  )
  expect(page).to have_content t('contacts.thank_you.page_title')
end

Then(/^I see an invalid contact request message$/) do
  expect(page).to have_selector(
    '.alert.alert-danger', text: t('simple_form.error_notification.default_message')
  )
end

Then(/^I should see the full contact request message$/) do
  expect(current_email.default_part_body.to_s).to include(@contact_request[:name])
  expect(current_email.default_part_body.to_s).to include(@contact_request[:email])
  expect(current_email.default_part_body.to_s).to include(@contact_request[:body])
end

Then(/^I should see it was sent from (.*)$/) do |page_name|
  referrer = "http://www.example.com#{path_to(page_name)}"
  expect(current_email.default_part_body.to_s).to include(referrer)
end
