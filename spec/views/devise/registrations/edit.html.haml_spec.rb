require 'rails_helper'

describe 'devise/registrations/edit.html.haml', type: :view do

  def stub_user_accounts(user, *accounts)
    skip_double_verification do
      decorated_accounts = AccountDecorator.decorate_collection(accounts)
      allow(accounts).to receive(:decorate).and_return(decorated_accounts)
    end
    allow(user).to receive(:accounts).and_return(accounts)
    allow(user).to receive(:provider_account?).and_return(true)
  end

  context 'with a user resource' do
    let(:user) { build_stubbed(:user) }
    let(:display_profile) { true }
    let(:display_password_change) { true }
    let(:display_accounts) { true }

    before(:each) do
      stub_devise_mappings
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')

      allow(view).to receive(:display_profile?).and_return(display_profile)
      allow(view).to receive(:display_password_change?).and_return(display_password_change)
      allow(view).to receive(:display_accounts?).and_return(display_accounts)
    end

    describe 'update profile form' do
      it 'renders the form' do
        render

        assert_select 'h3', 'Profile Information'
        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'input#user_name[name=?]', 'user[name]'
          assert_select 'input#user_email[name=?]', 'user[email]'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'user_name', 'Name'
        assert_select 'label[for=?]', 'user_email', 'Email'
      end
      it 'renders all form placeholders' do
        render

        assert_select '#user_name[placeholder=?]',
                      t('simple_form.placeholders.defaults.name')
        assert_select '#user_email[placeholder=?]',
                      t('simple_form.placeholders.defaults.email')
      end
    end

    describe 'the change password form' do
      it 'renders the change password form' do
        render

        assert_select 'h3', 'Change Password'
        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'input#user_password[name=?]', 'user[password]'
          assert_select 'input#user_password_confirmation[name=?]', 'user[password_confirmation]'
          assert_select 'input#user_current_password[name=?]', 'user[current_password]'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'user_password', 'New Password'
        assert_select 'label[for=?]', 'user_password_confirmation',
                      t('simple_form.labels.user.password_confirmation')
        assert_select 'label[for=?]', 'user_current_password', 'Current password'
      end
      it 'renders all form placeholders' do
        render

        assert_select '#user_password[placeholder=?]',
                      t('simple_form.placeholders.defaults.password')
        assert_select '#user_password_confirmation[placeholder=?]',
                      t('simple_form.placeholders.defaults.password_confirmation')
        assert_select '#user_current_password[placeholder=?]',
                      t('simple_form.placeholders.defaults.current_password')
      end
      it 'renders all hints' do
        render

        assert_select '.help-block', t('simple_form.hints.user.current_password')
      end
    end

    describe 'connected social media links' do

      describe 'sortable accounts list' do
        it 'renders the sortable list for multiple accounts' do
          facebook_account = build_stubbed(:facebook_account, user: user)
          twitter_account = build_stubbed(:twitter_account, user: user)
          stub_user_accounts(user, facebook_account, twitter_account)
          render

          linked_accounts_div = ".linked-accounts[data-sort-path='#{sort_users_accounts_path}']"
          assert_select linked_accounts_div, count: 1 do
            assert_select ".linked-facebook[data-account-id='#{facebook_account.id}']"
            assert_select ".linked-twitter[data-account-id='#{twitter_account.id}']"
          end
        end

        it 'the list is not sortable if the user has only one account' do
          twitter_account = build_stubbed(:twitter_account, user: user)
          stub_user_accounts(user, twitter_account)
          render

          assert_select '.linked-accounts:not([data-sort-path])', count: 1
        end
      end

      context 'with a Developer account' do
        let(:developer_account) { build_stubbed(:developer_account, user: user) }
        before(:each) do
          stub_user_accounts(user, developer_account)
        end

        it 'renders a Developer account summary' do
          render
          assert_select '.linked-developer' do
            assert_select 'a[disabled]', developer_account.uid
            assert_select 'a[href=?][data-method="delete"]', users_account_path(developer_account)
            assert_select 'i.fa.fa-user' # Generic FontAwesome icon
          end
        end
      end
      context 'with a Facebook account' do
        let(:facebook_account) { build_stubbed(:facebook_account, user: user) }
        before(:each) do
          stub_user_accounts(user, facebook_account)
        end

        it 'renders a Facebook account summary' do
          render
          assert_select '.linked-facebook' do
            assert_select 'a[href=?][rel="external"]', facebook_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(facebook_account)
            assert_select 'i.fa.fa-facebook' # FontAwesome icon
          end
        end
        it 'does not render a "Link your Facebook account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]',
                        user_omniauth_authorize_path('facebook'),
                        count: 0
        end
      end
      context 'with a Twitter account' do
        let(:twitter_account) { build_stubbed(:twitter_account, user: user) }
        before(:each) do
          stub_user_accounts(user, twitter_account)
        end
        it 'renders a Twitter account summary' do
          render
          assert_select '.linked-twitter' do
            assert_select 'a[href=?][rel="external"]', twitter_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(twitter_account)
            assert_select 'i.fa.fa-twitter' # FontAwesome icon
          end
        end
        it 'does not render a "Link your Twitter account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]',
                        user_omniauth_authorize_path('twitter'),
                        count: 0
        end
      end
      context 'with a GitHub account' do
        let(:github_account) { build_stubbed(:github_account, user: user) }
        before(:each) do
          stub_user_accounts(user, github_account)
        end

        it 'renders a GitHub account summary' do
          render
          assert_select '.linked-github' do
            assert_select 'a[href=?][rel="external"]', github_account.website
            assert_select 'a[href=?][data-method="delete"]', users_account_path(github_account)
            assert_select 'i.fa.fa-github' # FontAwesome icon
          end
        end
        it 'does not render a "Link your GitHub account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]',
                        user_omniauth_authorize_path('github'),
                        count: 0
        end
      end
      context 'with a Google account' do
        let(:google_oauth2_account) do
          build_stubbed(:google_oauth2_account, user: user, website: nil)
        end
        before(:each) do
          stub_user_accounts(user, google_oauth2_account)
        end

        it 'renders a Google account summary' do
          render
          assert_select '.linked-google-plus' do
            assert_select 'a[href="#"][disabled]' # Google has no website
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(google_oauth2_account)
            assert_select 'i.fa.fa-google-plus' # FontAwesome icon
          end
        end
        it 'does not render a "Link your Google account" link' do
          render
          assert_select 'a[href=?][rel="nofollow"]',
                        user_omniauth_authorize_path('google_oauth2'),
                        count: 0
        end
      end
    end

    describe 'connect social media links' do
      context 'with no Facebook account' do
        before(:each) { allow(user).to receive(:provider_account?).and_return(false) }
        it 'renders a "Link your Facebook account" link' do
          render
          assert_select '.connect-facebook' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('facebook')
          end
        end
      end
      context 'with no Twitter account' do
        before(:each) { allow(user).to receive(:provider_account?).and_return(false) }
        it 'renders a "Link your Twitter account" link' do
          render
          assert_select '.connect-twitter' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('twitter')
          end
        end
      end
      context 'with no GitHub account' do
        before(:each) { allow(user).to receive(:provider_account?).and_return(false) }
        it 'renders a "Link your GitHub account" link' do
          render
          assert_select '.connect-github' do
            assert_select 'a[href=?][rel="nofollow"]', user_omniauth_authorize_path('github')
          end
        end
      end
      context 'with no Google account' do
        before(:each) { allow(user).to receive(:provider_account?).and_return(false) }
        it 'renders a "Link your Google account" link' do
          render
          assert_select '.connect-google-plus' do
            assert_select 'a[href=?][rel="nofollow"]',
                          user_omniauth_authorize_path('google_oauth2')
          end
        end
      end
    end
  end
end
