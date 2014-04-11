### UTILITY METHODS ###

require Rails.root.join('spec', 'support', 'omniauth_helpers')

include OmniauthHelpers

### GIVEN ###

Given /^A user is already linked to a Developer account$/ do
  FactoryGirl.create(:account, :uid => developer_auth_hash.uid, :provider => 'developer')
end

Given /^A user is already linked to my GitHub account$/ do
  FactoryGirl.create(:github_account, github_credentials)
end

Given /^I exist as a user linked to my GitHub account$/ do
  create_user
  FactoryGirl.create(:github_account, github_credentials.merge({ user: @user }))
end

Given /^A user is already linked to my Google account$/ do
  FactoryGirl.create(:google_oauth2_account, google_credentials)
end

Given /^I exist as a user linked to my Google account$/ do
  create_user
  FactoryGirl.create(:google_oauth2_account, google_credentials.merge({user: @user}))
end

Given /^A user is already linked to my Facebook account$/ do
  FactoryGirl.create(:facebook_account, facebook_credentials)
end

Given /^I exist as a user linked to my Facebook account$/ do
  create_user
  FactoryGirl.create(:facebook_account, facebook_credentials.merge({user: @user}))
end

Given /^A user is already linked to my Twitter account$/ do
  FactoryGirl.create(:twitter_account, twitter_credentials)
end

Given /^I exist as a user linked to my Twitter account$/ do
  create_user
  FactoryGirl.create(:twitter_account, twitter_credentials.merge({user: @user}))
end

### WHEN ###

When /^I sign in using Developer auth$/ do
  set_oauth :developer, developer_auth_hash
  visit '/users/auth/developer'
end

When /^I sign in using my Facebook account$/ do
  set_oauth :facebook, facebook_auth_hash
  visit '/users/sign_in'
  click_link 'Facebook'

  page.body # No-op as background operation may not be complete
end

When /^I link my profile to my Facebook account$/ do
  set_oauth :facebook, facebook_auth_hash
  visit '/users/edit'
  click_link 'Link your Facebook account'
end

When /^I unlink my Facebook account$/ do
  visit '/users/edit'
  within('.btn-facebook') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When /^I sign in using my GitHub account$/ do
  set_oauth :github, github_auth_hash
  visit '/users/sign_in'
  click_link 'GitHub'

  page.body # No-op as background operation may not be complete
end

When /^I link my profile to my GitHub account$/ do
  set_oauth :github, github_auth_hash
  visit '/users/edit'
  click_link 'Link your GitHub account'
end

When /^I unlink my GitHub account$/ do
  visit '/users/edit'
  within('.btn-github') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When /^I link my profile to my Google account$/ do
  set_oauth :google_oauth2, google_auth_hash
  visit '/users/edit'
  click_link 'Link your Google account'
end

When /^I sign in using my Google account$/ do
  set_oauth :google_oauth2, google_auth_hash
  visit '/users/sign_in'
  click_link 'Google'

  page.body # No-op as background operation may not be complete
end

When /^I unlink my Google account$/ do
  visit '/users/edit'
  within('.btn-google-plus') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

When /^I sign in using my Twitter account$/ do
  set_oauth :twitter, twitter_auth_hash
  visit '/users/sign_in'
  click_link 'Twitter'

  page.body # No-op as background operation may not be complete
end

When /^I link my profile to my Twitter account$/ do
  set_oauth :twitter, twitter_auth_hash
  visit '/users/edit'
  click_link 'Link your Twitter account'
end

When /^I unlink my Twitter account$/ do
  visit '/users/edit'
  within('.btn-twitter') do
    find('a.unlink-account').click
  end
  page.driver.browser.switch_to.alert.accept if page.driver.browser.respond_to? :switch_to
end

### THEN ###

Then /^I should see a sign up form with my Developer credentials$/ do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  page.should have_content('Developer account')
  find('a[disabled=disabled]').text.should eq(@auth_account[:email])
end

Then /^I should see a successful Developer authentication message$/ do
  page.should have_content "Successfully authenticated from Developer account."
end

Then /^I should see a failed Developer sign in message$/ do
  page.should have_content 'Could not authenticate you from Developer because "Authentication is disabled from this Provider".'
end

Then /^I should be linked to my Developer account$/ do
  visit '/users/edit'
  Account.last.provider.should eq('developer')
end

Then /^I should see a sign up form with my Facebook credentials$/ do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-facebook') do
    page.should have_content('Facebook account')
    find_link(@auth_account[:name])[:href].should eq(@facebook_credentials[:website])
  end
end

Then /^I should see a successful Facebook authentication message$/ do
  page.should have_content "Successfully authenticated from Facebook account."
end

Then /^I should see a failed Facebook authentication message$/ do
  page.should have_content 'Could not authenticate you from Facebook because "Someone has already linked to this account".'
end

Then /^I should be linked to my Facebook account$/ do
  visit '/users/edit'
  page.should have_css('a.unlink-facebook')
  find_link(@auth_account[:name])[:href].should eq(@facebook_credentials[:website])
end

Then /^I should not be linked to a Facebook account$/ do
  visit '/users/edit'
  page.should_not have_css('a.unlink-facebook')
  find_link('Link your Facebook account').should be_visible
end

Then /^I should see a Facebook successfully unlinked message$/ do
  page.should have_content('Successfully unlinked your Facebook account')
end

Then /^I should see a sign up form with my GitHub credentials$/ do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-github') do
    page.should have_content('GitHub account')
    find_link(@github_credentials[:nickname])[:href].should eq(@github_credentials[:website])
  end
end

Then /^I should see a successful GitHub authentication message$/ do
  page.should have_content "Successfully authenticated from GitHub account."
end

Then /^I should see a failed GitHub authentication message$/ do
  page.should have_content 'Could not authenticate you from GitHub because "Someone has already linked to this account".'
end

Then /^I should be linked to my GitHub account$/ do
  visit '/users/edit'
  page.should have_css('a.unlink-github')
  find_link(@github_credentials[:nickname])[:href].should eq(@github_credentials[:website])
end

Then /^I should not be linked to a GitHub account$/ do
  visit '/users/edit'
  page.should_not have_css('a.unlink-github')
  find_link('Link your GitHub account').should be_visible
end

Then /^I should see a GitHub successfully unlinked message$/ do
  page.should have_content('Successfully unlinked your GitHub account')
end

Then /^I should see a sign up form with my Google credentials$/ do
  find_field('Name').value.should eq(@auth_account[:name])
  find_field('Email').value.should eq(@auth_account[:email])
  within('.btn-google-plus') do
    page.should have_content('Google account')
    find_link(@auth_account[:name])
  end
end

Then /^I should see a successful Google authentication message$/ do
  page.should have_content "Successfully authenticated from Google account."
end

Then /^I should see a failed Google authentication message$/ do
  page.should have_content 'Could not authenticate you from Google because "Someone has already linked to this account".'
end

Then /^I should be linked to my Google account$/ do
  visit '/users/edit'
  page.should have_css('a.unlink-google-plus')
  find_link(@auth_account[:name])
end

Then /^I should not be linked to a Google account$/ do
  visit '/users/edit'
  page.should_not have_css('a.unlink-google-plus')
  find_link('Link your Google account').should be_visible
end

Then /^I should see a Google successfully unlinked message$/ do
  page.should have_content('Successfully unlinked your Google account')
end

Then /^I should see a sign up form with my Twitter credentials$/ do
  find_field('Name').value.should eq(@auth_account[:name])
  within('.btn-twitter') do
    page.should have_content('Twitter account')
    find_link("@#{@twitter_credentials[:nickname]}")[:href].should eq(@twitter_credentials[:website])
  end
end

Then /^I should see a successful Twitter authentication message$/ do
  page.should have_content "Successfully authenticated from Twitter account."
end

Then /^I should see a failed Twitter authentication message$/ do
  page.should have_content 'Could not authenticate you from Twitter because "Someone has already linked to this account".'
end

Then /^I should be linked to my Twitter account$/ do
  visit '/users/edit'
  page.should have_css('a.unlink-twitter')
  find_link("@#{@auth_account[:nickname]}")[:href].should eq(@twitter_credentials[:website])
end

Then /^I should not be linked to a Twitter account$/ do
  visit '/users/edit'
  page.should_not have_css('a.unlink-twitter')
  find_link('Link your Twitter account').should be_visible
end

Then /^I should see a Twitter successfully unlinked message$/ do
  page.should have_content('Successfully unlinked your Twitter account')
end
