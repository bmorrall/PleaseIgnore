require 'rails_helper'

feature 'User Version History', :csrf_protection do
  scenario 'Review Account History' do
    # Given there is a admin user
    password = 'password123' || Faker::Internet.password
    admin = create(:user, :admin, password: password, password_confirmation: password)

    # And I am signed in as the admin
    sign_in_with_credentials admin.email, password

    # When I view my account history
    click_link 'History'

    # Then I should see a user created Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.user.create')

    # And I should see a User Role Assigned Version
    assert_selector '.versions-list .list-group-item-heading',
                    text: t('decorators.versions.title.role.user_create', role: 'Admin')
  end

  scenario 'View Version Summary', js: true do
    # Given there is a admin user
    password = 'password123' || Faker::Internet.password
    admin = create(:user, :admin, password: password, password_confirmation: password)

    # And I am signed in as the admin
    sign_in_with_credentials admin.email, password

    # When I view my account history
    click_link 'History'

    # And I click on the User Create Version
    find(
      '.versions-list .list-group-item-heading',
      text: t('decorators.versions.title.user.create')
    ).click

    # Then I should see the Version summary
    assert_selector '.versions-list .user-location', text: 'rspec', visible: true
    within('pre.list-group-item-text') do
      expect(page).to have_content admin.email
      expect(page).to have_content admin.name
    end
  end

  # WHEN

  def sign_in_with_credentials(email, password = nil)
    visit new_user_session_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password if password
    click_button 'Sign in'
  end
end
