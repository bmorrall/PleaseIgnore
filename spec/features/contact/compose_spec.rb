require 'rails_helper'

feature 'Contact Compose', type: :feature do
  scenario 'Form is pre-populated for logged in users', :login_user do
    visit_contact_page_from_dashboard
    assert_user_params_disabled
    assert_user_details_pre_populated
    assert_contact_referer(dashboard_url)
    assert_contact_body_text('')
  end

  def assert_user_params_disabled
    assert_selector 'input#contact_name[disabled]'
    assert_selector 'input#contact_email[disabled]'
    assert_selector 'textarea#contact_body:not([disabled])'
  end

  def assert_user_details_pre_populated
    assert_selector "input#contact_name[value='#{logged_in_user.name}']"
    assert_selector "input#contact_email[value='#{logged_in_user.email}']"
  end

  def assert_contact_referer(referer)
    assert_selector "input#contact_referer[value='#{referer}']", visible: false
  end

  def assert_contact_body_text(body_text)
    assert_selector 'textarea#contact_body', text: body_text
  end

  def visit_contact_page_from_dashboard
    # Given I am at the dashboard page
    visit dashboard_path

    # When I visit the contact form
    within 'nav.navbar' do
      click_link t('layouts.navbar_items.contact')
    end
  end
end
