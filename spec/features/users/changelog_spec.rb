require 'rails_helper'

feature 'User Changelog', type: :feature do
  scenario 'Review Changes to Profile', :login_admin do
    # When I view my profile changelog
    visit_profile_changelog_page

    # Then I should see a user created Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.user.create')

    # And I should see a User Role Assigned Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.role.user_create', role: 'Admin')
  end

  scenario 'View Version Summary', :js, :login_admin do
    # When I view my profile changelog
    visit_profile_changelog_page

    # And I click on the User Create Version
    find(
      '.versions-list .list-group-item-heading',
      text: t('decorators.versions.title.user.create')
    ).click

    # Then I should see the Version summary
    assert_selector '.versions-list .user-location', visible: true
    within('.change-summary') do
      expect(page).to have_content logged_in_user.email
      expect(page).to have_content logged_in_user.name
    end
  end

  def visit_profile_changelog_page
    navigate_to_my_profile
    click_link 'changelog'
  end
end
