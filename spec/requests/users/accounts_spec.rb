require 'spec_helper'

describe 'Users::Accounts' do

  describe 'DELETE /users/accounts/1' do
    context 'as a user belonging to the account' do
      login_user
      let!(:account) { FactoryGirl.create(:facebook_account, user: logged_in_user) }
      it 'redirects back to the users profile' do
        delete users_account_path(account)
        expect(response).to redirect_to edit_user_registration_path
      end
      it 'displays a success notice to the user' do
        delete users_account_path(account)
        follow_redirect!

        assert_select '.alert.alert-success strong', 'Successfully unlinked your Facebook account.'
      end
    end
    context 'as a user not belonging to the account' do
      login_user
      let!(:account) { FactoryGirl.create(:facebook_account) }
      it 'redirects back to the users profile' do
        delete users_account_path(account)
        expect(response).to redirect_to edit_user_registration_path
      end
      it 'displays a failure notice to the user' do
        delete users_account_path(account)
        follow_redirect!

        assert_select '.alert.alert-warning strong', 'Your account has already been unlinked.'
      end
    end
  end

end
