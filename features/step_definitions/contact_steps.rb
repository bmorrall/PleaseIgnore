
When /^I send a contact request$/ do
  within 'nav.navbar' do
    click_link "Contact"
  end
  fill_in 'contact_name', :with => "Example User"
  fill_in 'contact_email', :with => 'user@example.com'
  fill_in 'contact_body', :with => "I am making a contact request"
  click_button 'Send'
end

Then /^I should see a thank you message$/ do
  page.should have_content 'Thank you for Contacting PleaseIgnore'
end
