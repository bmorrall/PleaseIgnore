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
      it 'renders the form' do
        render

        assert_select 'form[action=?][method=?]', user_registration_path, 'post' do
          assert_select 'input#user_name[name=?]', 'user[name]'
          assert_select 'input#user_email[name=?]', 'user[email]'
          assert_select 'input#user_password[name=?]', 'user[password]'
          assert_select 'input#user_password_confirmation[name=?]', 'user[password_confirmation]'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'user_name', 'Name'
        assert_select 'label[for=?]', 'user_email', 'Email'
        assert_select 'label[for=?]', 'user_password', 'Password'
        assert_select 'label[for=?]', 'user_password_confirmation',
                      t('simple_form.labels.user.password_confirmation')
      end
      it 'renders all form placeholders' do
        render

        assert_select '#user_name[placeholder=?]',
                      t('simple_form.placeholders.defaults.name')
        assert_select '#user_email[placeholder=?]',
                      t('simple_form.placeholders.defaults.email')
        assert_select '#user_password[placeholder=?]',
                      t('simple_form.placeholders.defaults.password')
        assert_select '#user_password_confirmation[placeholder=?]',
                      t('simple_form.placeholders.defaults.password_confirmation')
      end
    end

    describe 'new account links' do
      {
        facebook: 'facebook',
        twitter: 'twitter',
        github: 'github'
      }.each do |provider, display_class|
        it "renders a pending #{provider} account" do
          account = build(:"#{provider}_account")
          allow(user).to receive(:new_session_accounts).and_return([account])

          render
          assert_select ".btn-#{display_class}" do
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
        assert_select '.btn-google-plus' do
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
