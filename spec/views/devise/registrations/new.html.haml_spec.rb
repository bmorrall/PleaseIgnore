require 'spec_helper'

describe "devise/registrations/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
    end

    it "renders the new registration form" do
      render

      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_name[name=?]", "user[name]"
        assert_select "input#user_email[name=?]", "user[email]"
        assert_select "input#user_password[name=?]", "user[password]"
        assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
      end
    end

    describe 'new account links' do
      it 'renders a pending facebook account' do
        facebook_account = FactoryGirl.build_stubbed(:facebook_account)
        allow(user).to receive(:new_session_accounts).and_return([ facebook_account ])

        render
        assert_select '.btn-facebook' do
          assert_select 'a[href=?][rel="external"]', facebook_account.website
          assert_select 'a[href=?][data-method="delete"][rel="nofollow"]', users_account_path(facebook_account)
        end
      end
      it 'renders a pending twitter account' do
        twitter_account = FactoryGirl.build_stubbed(:twitter_account)
        allow(user).to receive(:new_session_accounts).and_return([ twitter_account ])

        render
        assert_select '.btn-twitter' do
          assert_select 'a[href=?][rel="external"]', twitter_account.website
          assert_select 'a[href=?][data-method="delete"][rel="nofollow"]', users_account_path(twitter_account)
        end
      end
      it 'renders a pending github account' do
        github_account = FactoryGirl.build_stubbed(:github_account)
        allow(user).to receive(:new_session_accounts).and_return([ github_account ])

        render
        assert_select '.btn-github' do
          assert_select 'a[href=?][rel="external"]', github_account.website
          assert_select 'a[href=?][data-method="delete"][rel="nofollow"]', users_account_path(github_account)
        end
      end
      it 'renders a pending google account' do
        google_account = FactoryGirl.build_stubbed(:google_account, website: nil)
        allow(user).to receive(:new_session_accounts).and_return([ google_account ])

        render
        assert_select '.btn-google-plus' do
          assert_select 'a[href="#"][disabled]' # Google has no website
          assert_select 'a[href=?][data-method="delete"][rel="nofollow"]', users_account_path(google_account)
        end
      end
    end

    it "renders a link to the tos and privacy policy" do
      render

      assert_select 'a[href=?][rel="external"]', page_path('privacy')
      assert_select 'a[href=?][rel="external"]', page_path('terms')
    end
  end

end
