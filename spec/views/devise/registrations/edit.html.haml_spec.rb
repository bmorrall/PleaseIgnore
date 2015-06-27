require 'rails_helper'

describe 'devise/registrations/edit.html.haml', type: :view do
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
  end
end
