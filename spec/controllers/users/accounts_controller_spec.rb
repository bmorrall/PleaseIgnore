require 'spec_helper'

describe Users::AccountsController do

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
