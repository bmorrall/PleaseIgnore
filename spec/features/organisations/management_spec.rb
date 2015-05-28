require 'rails_helper'

feature 'Organisation Management' do
  scenario 'viewing an organsiation dashboard', :login_user do
    # Given I am the owner of an organisation
    organisation = create(:organisation)
    logged_in_user.add_role :owner, organisation

    # And I am at the Dashboard
    visit dashboard_url

    # When I select my organisation
    within 'nav.navbar' do
      find('.organisation-navbar a.dropdown-toggle').click
      click_on organisation.name
    end

    # Then I should be at the organisation page
    expect(page).to have_selector('.page-header', text: organisation.name)
  end

  scenario 'updating a organisation', :js, :login_user do
    # Given I am the owner of an organisation
    organisation = create(:organisation)
    logged_in_user.add_role :owner, organisation

    # When I open the organisation settings
    visit organisation_path(organisation)
    within 'aside.sidenav' do
      click_link 'Settings'
    end

    # And I update the organisation
    updated_name = Faker::Company.name
    fill_in 'organisation_name', with: updated_name
    click_button 'Update Organisation'

    # Then I should see the updated Organisation details
    expect(page).to have_content(
      t('flash.actions.update.notice', resource_name: 'Organisation')
    )
    expect(page).to have_selector('.page-header', text: updated_name)
  end
end
