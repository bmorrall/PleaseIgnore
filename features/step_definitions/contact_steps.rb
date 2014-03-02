
def create_contact_request
  @contact_request ||= {
    name: 'Example User',
    email: 'user@example.com',
    body: 'I am making a contact request'
  }
end

def begin_contact_request
  within 'nav.navbar' do
    click_link "Contact"
  end
end

def fill_in_and_send_contact_request
  create_contact_request
  fill_in 'contact_name', :with => @contact_request[:name]
  fill_in 'contact_email', :with => @contact_request[:email]
  fill_in 'contact_body', :with => @contact_request[:body]
  click_button 'Send'
end

### GIVEN

Given /^A visitor has sent a contact request from (.*)$/ do |page_name|
  visit path_to(page_name)
  begin_contact_request
  fill_in_and_send_contact_request
  page.driver.submit :delete, "/users/sign_out", {}
end

### WHEN

When /^I send a contact request$/ do
  begin_contact_request
  fill_in_and_send_contact_request
end

When /^I begin a new contact request$/ do
  begin_contact_request
end

When /^I submit an incomplete contact request$/ do
  begin_contact_request
  click_button 'Send'
end

### THEN

Then /^I should be notified I am making a request from (.+)$/ do |page_name|
  page.should have_content "Your message will mention you visited this page from #{current_host_with_port}#{path_to(page_name)}"
end

Then /^I should see my name and email on the contact form$/ do
  find_field('contact_name').value.should eq(@visitor[:name])
  find_field('contact_email').value.should eq(@visitor[:email])
end

Then /^I should see a thank you message$/ do
  page.should have_content 'Thank you for Contacting PleaseIgnore'
end

Then /^I see an invalid contact request message$/ do
  page.should have_content 'Please review the problems below'
end

Then /^I should see the full contact request message$/ do
  current_email.default_part_body.to_s.should include(@contact_request[:name])
  current_email.default_part_body.to_s.should include(@contact_request[:email])
  current_email.default_part_body.to_s.should include(@contact_request[:body])
end

Then /^I should see it was sent from (.*)$/ do |page_name|
  referrer = "http://www.example.com#{path_to(page_name)}"
  current_email.default_part_body.to_s.should include(referrer)
end

