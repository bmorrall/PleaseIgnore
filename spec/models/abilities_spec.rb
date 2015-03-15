require 'rails_helper'
require 'cancan/matchers'

describe User, type: :model do

  describe 'abilities' do
    let(:user) { nil }
    subject { Ability.new(user) }

    shared_examples 'a standard user' do
      # Contacts
      it { is_expected.to be_able_to(:create, Contact) }
    end

    describe 'as a guest' do
      # Contacts
      it { is_expected.to be_able_to(:create, Contact) }
    end

    describe 'as a user' do
      let(:user) { build_stubbed(:user) }

      it_behaves_like 'a standard user'

      # Versions
      it { is_expected.to_not be_able_to(:read, PaperTrail::Version) }
    end

    describe 'as a admin' do
      let(:user) { create(:user, :admin) }

      it_behaves_like 'a standard user'

      # Versions
      it { is_expected.to be_able_to(:read, PaperTrail::Version) }
    end

    describe 'as a banned user' do
      let(:user) { create(:user, :banned) }

      # Versions
      it { is_expected.not_to be_able_to(:read, PaperTrail::Version) }
    end

    describe 'Account abilities' do
      context 'as a guest' do
        it { is_expected.to be_able_to(:create, Account) }
      end
      context 'as a user' do
        let(:user) { create(:user) }

        it { is_expected.to be_able_to(:create, Account) }

        context 'with an account belonging to the user' do
          let(:account) { create :developer_account, user: user }

          it { is_expected.to be_able_to(:update, account) }
          it { is_expected.to be_able_to(:destroy, account) }
        end
        context 'with an account belonging to another user' do
          let(:another_user) { create :user }
          let(:account) { create :developer_account, user: another_user }

          it { is_expected.to_not be_able_to(:update, account) }
          it { is_expected.to_not be_able_to(:destroy, account) }
        end
      end
      context 'as a user with no login password' do
        let(:user) { create(:user, :no_login_password) }
        let(:account) { user.accounts.first }

        it 'should not allow the user to delete the account with no remaining accounts' do
          is_expected.to_not be_able_to(:destroy, account)
        end
        it 'should allow the user to delete the account with additional accounts' do
          create :facebook_account, user: user
          is_expected.to be_able_to(:destroy, account)
        end
      end
      context 'as a banned user' do
        let(:user) { create(:user, :banned) }

        it { is_expected.not_to be_able_to(:create, Account) }

        context 'with an account belonging to the user' do
          context 'with an account belonging to the user' do
            let(:account) { create :developer_account, user: user }

            it { is_expected.to_not be_able_to(:update, account) }
            it { is_expected.to_not be_able_to(:destroy, account) }
          end
        end
      end
    end

    describe 'Organisation abilities' do
      context 'as a guest' do
        it { is_expected.to_not be_able_to(:create, Organisation) }
      end
      context 'as a user' do
        let(:user) { create(:user) }

        it { is_expected.to be_able_to(:create, Organisation) }

        context 'with a persisted organisation' do
          let(:organisation) { create :organisation }

          it { is_expected.to_not be_able_to(:read, organisation) }
          it { is_expected.to_not be_able_to(:update, organisation) }
          it { is_expected.to_not be_able_to(:destroy, organisation) }
        end

        context 'when the user owns the organisation' do
          let(:organisation) { create :organisation }
          before(:each) { user.add_role :owner, organisation }

          it { is_expected.to be_able_to(:read, organisation) }
          it { is_expected.to be_able_to(:update, organisation) }
          it { is_expected.to be_able_to(:destroy, organisation) }
        end
      end
      context 'as a banned user' do
        let(:user) { create(:user, :banned) }

        it { is_expected.to_not be_able_to(:create, Organisation) }

        context 'when the user owns the organisation' do
          let(:organisation) { create :organisation }
          before(:each) { user.add_role :owner, organisation }

          it { is_expected.to_not be_able_to(:read, organisation) }
          it { is_expected.to_not be_able_to(:update, organisation) }
          it { is_expected.to_not be_able_to(:destroy, organisation) }
        end
      end
    end
  end
end
