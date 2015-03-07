### UTILITY METHODS ###

require Rails.root.join('spec', 'support', 'omniauth_helpers')

include OmniauthHelpers

### GIVEN ###

Given(/^I am already linked to my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  auth_hash = provider_auth_hash(provider)
  create(:"#{provider}_account", uid: auth_hash.uid)
end

Given(/^I exist as a user linked to my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  auth_hash = provider_auth_hash(provider)
  create_user
  create(:"#{provider}_account", user: @user, uid: auth_hash.uid)
end

### WHEN ###

When(/^I sign in using a Developer account$/) do
  set_oauth :developer, developer_auth_hash
  visit '/users/auth/developer'
end

When(/^I sign in using my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  auth_hash = provider_auth_hash(provider)

  set_oauth provider, auth_hash
  navigate_to 'the sign in page'
  click_link provider_name

  page.body # No-op as background operation may not be complete
end

When(/^I link my profile to my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  auth_hash = provider_auth_hash(provider)

  set_oauth provider, auth_hash
  navigate_to 'my profile page'
  click_link t('users.accounts.buttons.link_account', provider_name: provider_name)
end

When(/^I unlink my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  provider_class = provider == :google_oauth2 ? 'google-plus' : provider.to_s

  navigate_to 'my profile page'
  within(".linked-#{provider_class}") do
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

Then(/^I should see a failed Developer sign in message$/) do
  expect(page).to have_content(
    t('devise.omniauth_callbacks.failure',
      kind: 'Developer',
      reason: t('account.reasons.failure.account_disabled')
    )
  )
end

Then(/^I should be linked to my (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  provider_class = provider == :google_oauth2 ? 'google-plus' : provider.to_s

  navigate_to 'my profile page'
  expect(page).to have_css("a.unlink-#{provider_class}")

  account = Account.last
  expect(account.provider).to eq(provider)
  within(".linked-#{provider_class}") do
    if [:developer, :google_oauth2].include? provider
      find_link(account.account_uid)
    else
      expect(page).to have_content("#{provider_name} account")
      expect(
        find_link(account.account_uid)[:href]
      ).to eq(account.website)
    end
  end
end

Then(/^I should not be linked to a (.+) account$/) do |provider_name|
  provider = provider_from_name(provider_name)
  provider_class = provider == :google_oauth2 ? 'google-plus' : provider.to_s

  navigate_to 'my profile page'
  expect(page).to_not have_css(".linked-#{provider_class}")
  expect(page).to_not have_css("a.unlink-#{provider_class}")
  expect(
    find_link(t('users.accounts.buttons.link_account', provider_name: provider_name))
  ).to be_visible
end

Then(/^I should see a sign up form with my (.+) credentials$/) do |provider_name|
  provider = provider_from_name(provider_name)
  provider_class = provider == :google_oauth2 ? 'google-plus' : provider.to_s
  credentials = provider_credentials(provider)

  expect(find_field('Name').value).to eq(credentials[:name])
  expect(find_field('Email').value).to eq(credentials[:email]) unless provider == :twitter

  within(".pending-#{provider_class}") do
    expect(page).to have_content("#{provider_name} account")
    if [:developer, :google_oauth2].include? provider
      expect(page).to have_selector('a[disabled]')
    else
      expect(page).to have_selector("a[href='#{credentials[:website]}']")
    end
  end
end
