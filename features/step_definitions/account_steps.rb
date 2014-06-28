### UTILITY METHODS ###

require Rails.root.join('spec', 'support', 'omniauth_helpers')

include OmniauthHelpers

### GIVEN ###

Given(/^A user is already linked to a Developer account$/) do
  create(:developer_account, uid: developer_auth_hash.uid)
end

Given(/^A user is already linked to my GitHub account$/) do
  create(:github_account, github_credentials)
end

Given(/^I exist as a user linked to my GitHub account$/) do
  create_user
  create(:github_account, github_credentials.merge(user: @user))
end

Given(/^A user is already linked to my Google account$/) do
  create(:google_oauth2_account, google_credentials)
end

Given(/^I exist as a user linked to my Google account$/) do
  create_user
  create(:google_oauth2_account, google_credentials.merge(user: @user))
end

Given(/^A user is already linked to my Facebook account$/) do
  create(:facebook_account, facebook_credentials)
end

Given(/^I exist as a user linked to my Facebook account$/) do
  create_user
  create(:facebook_account, facebook_credentials.merge(user: @user))
end

Given(/^A user is already linked to my Twitter account$/) do
  create(:twitter_account, twitter_credentials)
end

Given(/^I exist as a user linked to my Twitter account$/) do
  create_user
  create(:twitter_account, twitter_credentials.merge(user: @user))
end

### WHEN ###

When(/^I sign in using Developer auth$/) do
  set_oauth :developer, developer_auth_hash
  visit '/users/auth/developer'
end

When(/^I sign in using my Facebook account$/) do
  set_oauth :facebook, facebook_auth_hash
  visit '/users/sign_in'
  click_link 'Facebook'

  page.body # No-op as background operation may not be complete
end

When(/^I link my profile to my Facebook account$/) do
  set_oauth :facebook, facebook_auth_hash
  visit '/users/edit'
  click_link t('users.accounts.buttons.link_account', provider_name: 'Facebook')
end

When(/^I unlink my Facebook account$/) do
  visit '/users/edit'
  within('.btn-facebook') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When(/^I sign in using my GitHub account$/) do
  set_oauth :github, github_auth_hash
  visit '/users/sign_in'
  click_link 'GitHub'

  page.body # No-op as background operation may not be complete
end

When(/^I link my profile to my GitHub account$/) do
  set_oauth :github, github_auth_hash
  visit '/users/edit'
  click_link t('users.accounts.buttons.link_account', provider_name: 'GitHub')
end

When(/^I unlink my GitHub account$/) do
  visit '/users/edit'
  within('.btn-github') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When(/^I link my profile to my Google account$/) do
  set_oauth :google_oauth2, google_oauth2_hash
  visit '/users/edit'
  click_link t('users.accounts.buttons.link_account', provider_name: 'Google')
end

When(/^I sign in using my Google account$/) do
  set_oauth :google_oauth2, google_oauth2_hash
  visit '/users/sign_in'
  click_link 'Google'

  page.body # No-op as background operation may not be complete
end

When(/^I unlink my Google account$/) do
  visit '/users/edit'
  within('.btn-google-plus') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When(/^I sign in using my Twitter account$/) do
  set_oauth :twitter, twitter_auth_hash
  visit '/users/sign_in'
  click_link 'Twitter'

  page.body # No-op as background operation may not be complete
end

When(/^I link my profile to my Twitter account$/) do
  set_oauth :twitter, twitter_auth_hash
  visit '/users/edit'
  click_link t('users.accounts.buttons.link_account', provider_name: 'Twitter')
end

When(/^I unlink my Twitter account$/) do
  visit '/users/edit'
  within('.btn-twitter') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

### THEN ###

Then(/^I should see a successful (.+) authentication message$/) do |provider|
  page.should have_content t('devise.omniauth_callbacks.success_authenticated', kind: provider)
end

Then(/^I should see a successful (.+) linked message$/) do |provider|
  page.should have_content t('devise.omniauth_callbacks.success_linked', kind: provider)
end

Then(/^I should see a successful (.+) registration message$/) do |provider|
  page.should have_content(
    t('devise.omniauth_callbacks.success_registered', kind: provider)
  )
end

Then(/^I should see a failed (.+) authentication message$/) do |provider|
  page.should have_content(
    t('devise.omniauth_callbacks.failure',
      kind: provider,
      reason: t('account.reasons.failure.previously_linked')
    )
  )
end

Then(/^I should see a (.+) successfully unlinked message$/) do |provider|
  page.should have_content(t('flash.users.accounts.destroy.notice', provider_name: provider))
end

Then(/^I should see a sign up form with my Developer credentials$/) do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  page.should have_content('Developer account')
  find('a[disabled=disabled]').text.should eq(@auth_account[:email])
end

Then(/^I should see a failed Developer sign in message$/) do
  page.should have_content(
    t('devise.omniauth_callbacks.failure',
      kind: 'Developer',
      reason: t('account.reasons.failure.provider_disabled')
    )
  )
end

Then(/^I should be linked to my Developer account$/) do
  visit '/users/edit'
  Account.last.provider.should eq(:developer)
end

Then(/^I should see a sign up form with my Facebook credentials$/) do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-facebook') do
    page.should have_content('Facebook account')
    find_link(@auth_account[:name])[:href].should eq(@facebook_credentials[:website])
  end
end

Then(/^I should be linked to my Facebook account$/) do
  visit '/users/edit'
  page.should have_css('a.unlink-facebook')
  find_link(@auth_account[:name])[:href].should eq(@facebook_credentials[:website])
end

Then(/^I should not be linked to a Facebook account$/) do
  visit '/users/edit'
  page.should_not have_css('a.unlink-facebook')
  find_link(t('users.accounts.buttons.link_account', provider_name: 'Facebook')).should be_visible
end

Then(/^I should see a sign up form with my GitHub credentials$/) do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-github') do
    page.should have_content('GitHub account')
    find_link(@github_credentials[:nickname])[:href].should eq(@github_credentials[:website])
  end
end

Then(/^I should be linked to my GitHub account$/) do
  visit '/users/edit'
  page.should have_css('a.unlink-github')
  find_link(@github_credentials[:nickname])[:href].should eq(@github_credentials[:website])
end

Then(/^I should not be linked to a GitHub account$/) do
  visit '/users/edit'
  page.should_not have_css('a.unlink-github')
  find_link(t('users.accounts.buttons.link_account', provider_name: 'GitHub')).should be_visible
end

Then(/^I should see a sign up form with my Google credentials$/) do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-google-plus') do
    page.should have_content('Google account')
    find_link(@auth_account[:name])
  end
end

Then(/^I should be linked to my Google account$/) do
  visit '/users/edit'
  page.should have_css('a.unlink-google-plus')
  find_link(@auth_account[:name])
end

Then(/^I should not be linked to a Google account$/) do
  visit '/users/edit'
  page.should_not have_css('a.unlink-google-plus')
  find_link(t('users.accounts.buttons.link_account', provider_name: 'Google')).should be_visible
end

Then(/^I should see a sign up form with my Twitter credentials$/) do
  find_field('Name').value.should eq(@auth_account[:name])
  within('.btn-twitter') do
    page.should have_content('Twitter account')
    find_link(
      "@#{@twitter_credentials[:nickname]}")[:href].should eq(@twitter_credentials[:website]
    )
  end
end

Then(/^I should be linked to my Twitter account$/) do
  visit '/users/edit'
  page.should have_css('a.unlink-twitter')
  find_link("@#{@auth_account[:nickname]}")[:href].should eq(@twitter_credentials[:website])
end

Then(/^I should not be linked to a Twitter account$/) do
  visit '/users/edit'
  page.should_not have_css('a.unlink-twitter')
  find_link(t('users.accounts.buttons.link_account', provider_name: 'Twitter')).should be_visible
end
