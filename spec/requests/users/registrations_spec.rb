require 'spec_helper'

describe 'Registrations' do

  describe 'GET new' do
    context 'as a visitor' do
      it 'renders the new page' do
        get new_user_registration_path
        expect(response.status).to be(200)
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get new_user_registration_path
        assert_select 'body.users-registrations.users-registrations-new'
      end
      it 'includes the page title' do
        get new_user_registration_path
        assert_select 'title', 'PleaseIgnore | Create Account'
      end
    end
  end

  describe 'POST create' do
    context 'as a visitor' do
      context 'with invalid account data' do
        include OmniauthHelpers

        before(:each) do
          # Ensure the Account fails validation
          expect_any_instance_of(Account).to receive(:valid?).and_return(false)

          # Fake a successful oauth attempt
          set_oauth :facebook, facebook_auth_hash
          post user_omniauth_authorize_path(:facebook)
          follow_redirect! # to callback path
          follow_redirect! # to user registration

          post user_registration_path,  user: attributes_for(:user)
        end

        it 'displays a failed login attempt to the user' do
          assert_select '.alert.alert-danger strong', 'Please review the problems below:'
          assert_select '.alert li', 'Unable to add your Facebook account'
        end
      end
    end
  end

end
