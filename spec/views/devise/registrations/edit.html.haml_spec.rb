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
      it 'renders the header' do
        render

        assert_select 'h3', 'Profile Information'
      end
      it 'renders the name field' do
        render

        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'label[for=?]', 'user_name', 'Name'
          assert_select 'input#user_name[name=?][placeholder=?]',
                        'user[name]',
                        t('simple_form.placeholders.defaults.name')
        end
      end
      it 'renders the email field' do
        render

        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'label[for=?]', 'user_email', 'Email'
          assert_select 'input#user_email[name=?][placeholder=?]',
                        'user[email]',
                        t('simple_form.placeholders.defaults.email')
        end
      end

      context 'with a confirmed user account' do
        let(:user) { build_stubbed(:user, :confirmed) }

        it 'should disable the email field' do
          render

          assert_select 'input#user_email[name=?][disabled]', 'user[email]'
        end
      end
    end

    describe 'the change password form' do
      it 'renders the new password field' do
        render

        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'label[for=?]', 'user_password', 'New Password'
          assert_select 'input#user_password[name=?][placeholder=?]',
                        'user[password]',
                        t('simple_form.placeholders.defaults.password')
        end
      end
      it 'renders the password confirmation field' do
        render

        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'label[for=?]', 'user_password_confirmation',
                        t('simple_form.labels.user.password_confirmation')
          assert_select 'input#user_password_confirmation[name=?][placeholder=?]',
                        'user[password_confirmation]',
                        t('simple_form.placeholders.defaults.password_confirmation')
        end
      end

      context 'when the user has a encrypted password' do
        before(:each) { allow(user).to receive(:no_login_password?).and_return(false) }

        it 'renders the Change Password header' do
          render

          assert_select 'h3', 'Change Password'
        end
        it 'renders the current password field' do
          render

          assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
            assert_select 'label[for=?]', 'user_current_password', 'Current Password'
            assert_select 'input#user_current_password[name=?][placeholder=?]',
                          'user[current_password]',
                          t('simple_form.placeholders.defaults.current_password')
            assert_select '.help-block', t('simple_form.hints.user.current_password')
          end
        end
      end
      context 'when the user does not have a password' do
        before(:each) { allow(user).to receive(:no_login_password?).and_return(true) }

        it 'renders the Add Login Password header' do
          render

          assert_select 'h3', 'Add Login Password'
        end
        it 'does not render the current password field' do
          render

          assert_select 'input#user_current_password', count: 0
        end
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
            assert_select 'i.fa.fa-user' # Generic FontAwesome icon
          end
        end
        it 'renders a delete button when the user has the destroy ability' do
          controller.current_ability.can :destroy, developer_account
          render
          assert_select '.linked-developer' do
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(developer_account)
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
            assert_select 'i.fa.fa-facebook' # FontAwesome icon
          end
        end
        it 'renders a delete button when the user has the destroy ability' do
          controller.current_ability.can :destroy, facebook_account
          render
          assert_select '.linked-facebook' do
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(facebook_account)
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
            assert_select 'i.fa.fa-twitter' # FontAwesome icon
          end
        end
        it 'renders a delete button when the user has the destroy ability' do
          controller.current_ability.can :destroy, twitter_account
          render
          assert_select '.linked-twitter' do
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(twitter_account)
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
            assert_select 'i.fa.fa-github' # FontAwesome icon
          end
        end
        it 'renders a delete button when the user has the destroy ability' do
          controller.current_ability.can :destroy, github_account
          render
          assert_select '.linked-github' do
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(github_account)
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
            assert_select 'i.fa.fa-google-plus' # FontAwesome icon
          end
        end
        it 'renders a delete button when the user has the destroy ability' do
          controller.current_ability.can :destroy, Account
          render
          assert_select '.linked-google-plus' do
            assert_select 'a[href=?][data-method="delete"]',
                          users_account_path(google_oauth2_account)
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
