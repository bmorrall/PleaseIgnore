require 'rails_helper'

feature 'User Version History', type: :feature do
  scenario 'Review Account History', :login_admin do
    # When I view my account history
    click_link 'History'

    # Then I should see a user created Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.user.create')

    # And I should see a User Role Assigned Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.role.user_create', role: 'Admin')
  end

  scenario 'View Version Summary', :js, :login_admin do
    # When I view my account history
    click_link 'History'

    # And I click on the User Create Version
    find(
      '.versions-list .list-group-item-heading',
      text: t('decorators.versions.title.user.create')
    ).click

    # Then I should see the Version summary
    assert_selector '.versions-list .user-location', visible: true
    within('pre.list-group-item-text') do
      expect(page).to have_content logged_in_user.email
      expect(page).to have_content logged_in_user.name
    end
  end
end
