require 'spec_helper'

describe "devise/registrations/edit.html.haml" do

  context do # Within default nesting
    let(:user) { FactoryGirl.build_stubbed(:user) }
    let(:display_profile) { true }
    let(:display_password_change) { true }
    let(:display_accounts) { true }

    before(:each) do
      view.stub(:devise_mapping).and_return(Devise.mappings[:user])
      view.stub(:resource).and_return(user)
      view.stub(:resource_name).and_return('user')

      view.stub(:display_profile?).and_return(display_profile)
      view.stub(:display_password_change?).and_return(display_password_change)
      view.stub(:display_accounts?).and_return(display_accounts)
    end

    it "renders the update profile form" do
      render

      assert_select "h3", 'Profile Information'
      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_name[name=?]", "user[name]"
        assert_select "input#user_email[name=?]", "user[email]"
      end
    end

    it "renders the change password form" do
      render

      assert_select "h3", 'Change Password'
      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_password[name=?]", "user[password]"
        assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
        assert_select "input#user_current_password[name=?]", "user[current_password]"
      end
    end

    describe 'connected social media links' do
      context 'with a Facebook account' do
        let(:facebook_account) { FactoryGirl.build_stubbed(:facebook_account, user: user) }
        before(:each) do
          user.stub(:accounts).and_return([facebook_account])
          user.stub(:has_provider_account?).and_return(true)
        end

        it 'renders a Facebook account summary' do
          render
          assert_select '.btn-facebook' do
            assert_select 'a[href=?][rel="external"]', facebook_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(facebook_account)
          end
        end
        it 'does not render a "Link your Facebook account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('facebook'), count: 0
        end
      end
      context 'with a Twitter account' do
        let(:twitter_account) { FactoryGirl.build_stubbed(:twitter_account, user: user) }
        before(:each) do
          user.stub(:accounts).and_return([twitter_account])
          user.stub(:has_provider_account?).and_return(true)
        end
        it 'renders a Twitter account summary' do
          render
          assert_select '.btn-twitter' do
            assert_select 'a[href=?][rel="external"]', twitter_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(twitter_account)
          end
        end
        it 'does not render a "Link your Twitter account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('twitter'), count: 0
        end
      end
      context 'with a github account' do
        let(:github_account) { FactoryGirl.build_stubbed(:github_account, user: user) }
        before(:each) do
          user.stub(:accounts).and_return([github_account])
          user.stub(:has_provider_account?).and_return(true)
        end

        it 'renders a GitHub account summary' do
          render
          assert_select '.btn-github' do
            assert_select 'a[href=?][rel="external"]', github_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(github_account)
          end
        end
        it 'does not render a "Link your GitHub account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('github'), count: 0
        end
      end
      context 'with a Google account' do
        let(:google_account) { FactoryGirl.build_stubbed(:google_account, user: user, website: nil) }
        before(:each) do
          user.stub(:accounts).and_return([google_account])
          user.stub(:has_provider_account?).and_return(true)
        end

        it 'renders a Google account summary' do
          render
          assert_select '.btn-google-plus' do
            assert_select 'a[href="#"][disabled]' # Google has no website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(google_account)
          end
        end
        it 'does not render a "Link your Google account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('google_oauth2'), count: 0
        end
      end
    end

    describe 'connect social media links' do
      context 'with no Facebook account' do
        before(:each) { user.stub(:has_provider_account?).and_return(false) }
        it 'renders a "Link your Facebook account" link' do
          render
          assert_select '.btn-facebook' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('facebook')
          end
        end
      end
      context 'with no Twitter account' do
        before(:each) { user.stub(:has_provider_account?).and_return(false) }
        it 'renders a "Link your Twitter account" link' do
          render
          assert_select '.btn-twitter' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('twitter')
          end
        end
      end
      context 'with no GitHub account' do
        before(:each) { user.stub(:has_provider_account?).and_return(false) }
        it 'renders a "Link your GitHub account" link' do
          render
          assert_select '.btn-github' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('github')
          end
        end
      end
      context 'with no Google account' do
        before(:each) { user.stub(:has_provider_account?).and_return(false) }
        it 'renders a "Link your Google account" link' do
          render
          assert_select '.btn-google-plus' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('google_oauth2')
          end
        end
      end
    end
  end

end
