require 'rails_helper'

feature 'User History', type: :feature do
  scenario 'Review Profile History', :js, :login_user do
    # Given I have updated an organisation
    create_organisation_update_version

    # When I view my profile history
    visit_profile_history_page

    # Then I should see a organisation updated Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: "Update Organisation ##{updated_organisation.id}"
  end

  scenario 'View Version Summary', :js, :login_user do
    # Given I have updated an organisation
    create_organisation_update_version

    # When I view my profile history
    visit_profile_history_page

    # And I click on the Organisation Update Version
    find(
      '.versions-list .list-group-item-heading',
      text: "Update Organisation ##{updated_organisation.id}"
    ).click

    # Then I should see the Version summary
    assert_selector '.versions-list .user-location', visible: true
    assert_selector '.change-summary', count: 0
  end

  def create_organisation_update_version
    whodunnit = "#{logged_in_user.id} #{logged_in_user.email}"
    create(
      :papertrail_version,
      :with_user_agent,
      item: updated_organisation,
      event: 'update',
      whodunnit: whodunnit
    )
  end

  def visit_profile_history_page
    navigate_to_my_profile
    click_link t('layouts.navigation.my_history')
  end

  def updated_organisation
    @updated_organisation ||= create(:organisation)
  end
end
