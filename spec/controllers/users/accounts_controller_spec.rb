require 'spec_helper'

describe Users::AccountsController do

  describe 'DELETE destroy' do
    context 'with a signed in User' do
      login_user
      context 'with a facebook account' do
        let!(:facebook_account) { FactoryGirl.create(:facebook_account, user: logged_in_user) }
        it 'should delete the user account' do
          expect {
            delete :destroy, id: facebook_account.to_param
          }.to change(Account, :count).by(-1)
        end
        context 'with a valid request' do
          before(:each) do
            delete :destroy, id: facebook_account.to_param
          end
          it { response.should redirect_to edit_user_registration_path }
          it { should set_the_flash[:notice].to('Successfully unlinked your Facebook account.') }
        end
      end
      context 'with a facebook account belonging to another user' do
        let!(:facebook_account) { FactoryGirl.create(:facebook_account) }
        it 'should not delete the user account' do
          expect {
            delete :destroy, id: facebook_account.to_param
          }.to_not change(Account, :count)
        end
        context 'with a valid request' do
          before(:each) do
            delete :destroy, id: facebook_account.to_param
          end
          it { response.should redirect_to edit_user_registration_path }
          it { should set_the_flash[:notice].to('Your account has already been unlinked.') }
        end
      end
    end
  end

  describe 'POST sort' do
    context 'with a signed in User' do
      login_user
      context 'with multiple accounts' do
        let!(:account_a) { FactoryGirl.create(:account, position: 1, user: logged_in_user) }
        let!(:account_b) { FactoryGirl.create(:account, position: 2, user: logged_in_user) }
        let!(:account_c) { FactoryGirl.create(:account, position: 3, user: logged_in_user) }
        context 'with a valid request' do
          before(:each) do
            post :sort, { :account_ids => [ account_b.id, account_c.id, account_a.id ] }
          end
          it { should respond_with(:success) }
          it 'reorders the accounts' do
            # Reload the accounts
            [account_a, account_b, account_c].each { |a| a.reload }

            # Accounts should be in sort order
            account_b.position.should eq(1)
            account_c.position.should eq(2)
            account_a.position.should eq(3)
          end
        end
        it 'only orders accounts belonging to the user' do
          account_extra = FactoryGirl.create(:account, position: 1)
          post :sort, { :account_ids => [ account_b.id, account_c.id, account_extra.id, account_a.id ] }
          account_extra.reload
          account_extra.position.should eq(1) # Position is unchanged
        end
      end
    end
  end
end
