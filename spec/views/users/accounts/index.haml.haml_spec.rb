require 'rails_helper'

describe 'users/accounts/index.html.haml', type: :view do
  context 'with a logged in user', :authenticated_view do
    let(:user) { create :user }
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
    end

    def stub_account_decoration(accounts)
      skip_double_verification do
        decorated_accounts = AccountDecorator.decorate_collection(accounts)
        allow(accounts).to receive(:decorate).and_return(decorated_accounts)
      end
    end

    def stub_user_accounts(user, *accounts)
      stub_account_decoration(accounts)
      assign(:accounts, accounts)
      allow(user).to receive(:accounts).and_return(accounts)
      allow(user).to receive(:provider_account?).and_return(true)
    end

    describe 'connected social media links' do
      describe 'sortable accounts list' do
        context 'when the user has the sort ability' do
          before(:each) { current_ability.can?(:sort, Account) }

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
      before(:each) { assign(:accounts, Account.none) }

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
