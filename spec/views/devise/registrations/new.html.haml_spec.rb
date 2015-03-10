require 'rails_helper'

describe 'devise/registrations/new.html.haml', type: :view do

  context 'with a new user resource' do
    let(:user) { User.new }
    before(:each) do
      stub_devise_mappings
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
    end

    describe 'the new registration form' do
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

      context 'when the user requires a password' do
        before(:each) { allow(user).to receive(:password_required?).and_return(true) }

        it 'renders the password field' do
          render

          assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
            assert_select 'label[for=?]', 'user_password', 'Password'
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
      end
    end

    it 'renders the social media login buttons' do
      render

      assert_select "a.btn-facebook[href=?][rel='nofollow']", '/users/auth/facebook'
      assert_select "a.btn-google-plus[href=?][rel='nofollow']", '/users/auth/google_oauth2'
      assert_select "a.btn-github[href=?][rel='nofollow']", '/users/auth/github'
      assert_select "a.btn-twitter[href=?][rel='nofollow']", '/users/auth/twitter'
    end

    describe 'pending account links' do
      {
        facebook: 'facebook',
        twitter: 'twitter',
        github: 'github'
      }.each do |provider, display_class|
        it "renders a pending #{provider} account" do
          account = build(:"#{provider}_account")
          allow(user).to receive(:new_session_accounts).and_return([account])

          render
          assert_select ".pending-#{display_class}" do
            assert_select 'a[href=?][rel="external"]', account.website
            assert_select 'a[href=?][data-method="get"][rel="nofollow"]',
                          cancel_user_registration_path
          end
        end
      end

      it 'renders a pending google account' do
        google_oauth2_account = build(:google_oauth2_account, website: nil)
        allow(user).to receive(:new_session_accounts).and_return([google_oauth2_account])

        render
        assert_select '.pending-google-plus' do
          assert_select 'a[href="#"][disabled]' # Google has no website
          assert_select 'a[href=?][data-method="get"][rel="nofollow"]',
                        cancel_user_registration_path
        end
      end
    end

    it 'renders a link to the tos and privacy policy' do
      render

      assert_select 'a[href=?][rel="external"]', page_path('privacy')
      assert_select 'a[href=?][rel="external"]', page_path('terms')
    end
  end

end
