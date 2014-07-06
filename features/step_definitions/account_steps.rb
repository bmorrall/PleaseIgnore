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
  expect(page).to have_content t('devise.omniauth_callbacks.success_authenticated', kind: provider)
end

Then(/^I should see a successful (.+) linked message$/) do |provider|
  expect(page).to have_content t('devise.omniauth_callbacks.success_linked', kind: provider)
end

Then(/^I should see a successful (.+) registration message$/) do |provider|
  expect(page).to have_content(
    t('devise.omniauth_callbacks.success_registered', kind: provider)
  )
end

Then(/^I should see a failed (.+) authentication message$/) do |provider|
  expect(page).to have_content(
    t('devise.omniauth_callbacks.failure',
      kind: provider,
      reason: t('account.reasons.failure.previously_linked')
    )
  )
end

Then(/^I should see a (.+) successfully unlinked message$/) do |provider|
  expect(page).to have_content(t('flash.users.accounts.destroy.notice', provider_name: provider))
end

Then(/^I should see a sign up form with my Developer credentials$/) do
  expect(find_field('Name').value).to eq(@auth_account[:name])
  expect(find_field('Email').value).to eq(@auth_account[:email])
  expect(page).to have_content('Developer account')
  expect(find('a[disabled=disabled]').text).to eq(@auth_account[:email])
end

Then(/^I should see a failed Developer sign in message$/) do
  expect(page).to have_content(
    t('devise.omniauth_callbacks.failure',
      kind: 'Developer',
      reason: t('account.reasons.failure.account_disabled')
    )
  )
end

Then(/^I should be linked to my Developer account$/) do
  visit '/users/edit'
  expect(Account.last.provider).to eq(:developer)
end

Then(/^I should see a sign up form with my Facebook credentials$/) do
  expect(find_field('Name').value).to eq(@auth_account[:name])
  expect(find_field('Email').value).to eq(@auth_account[:email])
  within('.btn-facebook') do
    expect(page).to have_content('Facebook account')
    expect(find_link(@auth_account[:name])[:href]).to eq(@facebook_credentials[:website])
  end
end

Then(/^I should be linked to my Facebook account$/) do
  visit '/users/edit'
  expect(page).to have_css('a.unlink-facebook')
  expect(find_link(@auth_account[:name])[:href]).to eq(@facebook_credentials[:website])
end

Then(/^I should not be linked to a Facebook account$/) do
  visit '/users/edit'
  expect(page).to_not have_css('a.unlink-facebook')
  expect(
    find_link(t('users.accounts.buttons.link_account', provider_name: 'Facebook'))
  ).to be_visible
end

Then(/^I should see a sign up form with my GitHub credentials$/) do
  expect(find_field('Name').value).to eq(@auth_account[:name])
  expect(find_field('Email').value).to eq(@auth_account[:email])
  within('.btn-github') do
    expect(page).to have_content('GitHub account')
    expect(find_link(@github_credentials[:nickname])[:href]).to eq(@github_credentials[:website])
  end
end

Then(/^I should be linked to my GitHub account$/) do
  visit '/users/edit'
  expect(page).to have_css('a.unlink-github')
  expect(find_link(@github_credentials[:nickname])[:href]).to eq(@github_credentials[:website])
end

Then(/^I should not be linked to a GitHub account$/) do
  visit '/users/edit'
  expect(page).to_not have_css('a.unlink-github')
  expect(
    find_link(t('users.accounts.buttons.link_account', provider_name: 'GitHub'))
  ).to be_visible
end

Then(/^I should see a sign up form with my Google credentials$/) do
  expect(find_field('Name').value).to eq(@auth_account[:name])
  expect(find_field('Email').value).to eq(@auth_account[:email])
  within('.btn-google-plus') do
    expect(page).to have_content('Google account')
    find_link(@auth_account[:name])
  end
end

Then(/^I should be linked to my Google account$/) do
  visit '/users/edit'
  expect(page).to have_css('a.unlink-google-plus')
  find_link(@auth_account[:name])
end

Then(/^I should not be linked to a Google account$/) do
  visit '/users/edit'
  expect(page).to_not have_css('a.unlink-google-plus')
  expect(
    find_link(t('users.accounts.buttons.link_account', provider_name: 'Google'))
  ).to be_visible
end

Then(/^I should see a sign up form with my Twitter credentials$/) do
  expect(find_field('Name').value).to eq(@auth_account[:name])
  within('.btn-twitter') do
    expect(page).to have_content('Twitter account')
    expect(
      find_link("@#{@twitter_credentials[:nickname]}")[:href]
    ).to eq(@twitter_credentials[:website])
  end
end

Then(/^I should be linked to my Twitter account$/) do
  visit '/users/edit'
  expect(page).to have_css('a.unlink-twitter')
  expect(find_link("@#{@auth_account[:nickname]}")[:href]).to eq(@twitter_credentials[:website])
end

Then(/^I should not be linked to a Twitter account$/) do
  visit '/users/edit'
  expect(page).to_not have_css('a.unlink-twitter')
  expect(
    find_link(t('users.accounts.buttons.link_account', provider_name: 'Twitter'))
  ).to be_visible
end
