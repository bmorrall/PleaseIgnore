require 'rails_helper'

describe Users::AccountsController, type: :controller do

  describe 'DELETE destroy' do
    context 'with a signed in User' do
      login_user
      grant_ability :destroy, Account

      context 'with a facebook account belonging to the user' do
        let!(:facebook_account) { create(:facebook_account, user: logged_in_user) }

        it 'should delete the user account' do
          expect do
            xhr :delete, :destroy, id: facebook_account.to_param
          end.to change(Account, :count).by(-1)
        end
        context 'with a valid xhr request' do
          before(:each) do
            xhr :delete, :destroy, id: facebook_account.to_param
          end

          it { expect(response).to redirect_to edit_user_registration_path }
          it do
            is_expected.to set_the_flash[:notice].to(
              t('flash.users.accounts.destroy.notice', provider_name: 'Facebook')
            )
          end
        end
      end
      context 'with a facebook account belonging to another user' do
        let!(:facebook_account) { create(:facebook_account) }

        it 'should not delete the user account' do
          expect do
            xhr :delete, :destroy, id: facebook_account.to_param
          end.to_not change(Account, :count)
        end
        context 'with a valid xhr request' do
          before(:each) do
            xhr :delete, :destroy, id: facebook_account.to_param
          end

          it { expect(response).to redirect_to edit_user_registration_path }
          it do
            is_expected.to set_the_flash[:warning].to(
              t('flash.users.accounts.destroy.warning')
            )
          end
        end
      end
    end
  end

  describe 'POST sort' do
    context 'with a signed in User' do
      login_user
      grant_ability :sort, Account

      context 'with multiple accounts' do
        let!(:account_a) { create(:developer_account, position: 1, user: logged_in_user) }
        let!(:account_b) { create(:facebook_account, position: 2, user: logged_in_user) }
        let!(:account_c) { create(:twitter_account, position: 3, user: logged_in_user) }

        context 'with a valid xhr request' do
          before(:each) do
            xhr :post, :sort, account_ids: [account_b.id, account_c.id, account_a.id]
          end

          it { is_expected.to respond_with(:success) }
          it 'reorders the accounts' do
            # Reload the accounts
            [account_a, account_b, account_c].each(&:reload)

            # Accounts should be in sort order
            expect(account_b.position).to eq(1)
            expect(account_c.position).to eq(2)
            expect(account_a.position).to eq(3)
          end
        end
        it 'only orders accounts belonging to the user' do
          account_extra = create(:developer_account, position: 1)
          account_ids = [
            account_b.id,
            account_c.id,
            account_extra.id,
            account_a.id
          ]
          xhr :post, :sort, account_ids: account_ids
          account_extra.reload
          expect(account_extra.position).to eq(1) # Position is unchanged
        end
      end
    end
  end
end
