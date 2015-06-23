require 'rails_helper'

describe 'Users::Accounts', type: :request do
  describe 'DELETE /users/accounts/1 AS xhr' do
    context 'as a user belonging to the account' do
      login_user
      let!(:account) { create(:facebook_account, user: logged_in_user) }
      it 'redirects back to the users profile' do
        xhr :delete, users_account_path(account)
        expect(response).to redirect_to edit_user_registration_path
      end
      it 'displays a success notice to the user' do
        xhr :delete, users_account_path(account)
        follow_redirect!

        assert_select '.alert.alert-success strong',
                      t('flash.users.accounts.destroy.notice', provider_name: 'Facebook')
      end
    end
    context 'as a user not belonging to the account' do
      login_user
      let!(:account) { create(:facebook_account) }
      it 'redirects back to the users profile' do
        xhr :delete, users_account_path(account)
        expect(response).to redirect_to edit_user_registration_path
      end
      it 'displays a failure notice to the user' do
        xhr :delete, users_account_path(account)
        follow_redirect!

        assert_select '.alert.alert-warning strong', t('flash.users.accounts.destroy.warning')
      end
    end
  end
end
