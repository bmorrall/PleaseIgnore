require 'rails_helper'
require 'cancan/matchers'

describe User, type: :model do

  describe 'abilities' do
    let(:user) { nil }
    subject { Ability.new(user) }

    shared_examples 'a standard user' do
      # Accounts
      it { is_expected.to be_able_to(:create, Account) }
      it { is_expected.to be_able_to(:update, build_stubbed(:developer_account, user: user)) }
      it { is_expected.to be_able_to(:destroy, build_stubbed(:developer_account, user: user)) }
      it { is_expected.not_to be_able_to(:update, build_stubbed(:developer_account)) }
      it { is_expected.not_to be_able_to(:destroy, build_stubbed(:developer_account)) }

      # Contacts
      it { is_expected.to be_able_to(:create, Contact) }
    end

    describe 'as a guest' do

      # Accounts
      it { is_expected.to be_able_to(:create, Account) }

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

      # Accounts
      it { is_expected.not_to be_able_to(:create, Account) }
      it { is_expected.not_to be_able_to(:update, build_stubbed(:developer_account, user: user)) }
      it { is_expected.not_to be_able_to(:destroy, build_stubbed(:developer_account, user: user)) }
      it { is_expected.not_to be_able_to(:update, Account) }
      it { is_expected.not_to be_able_to(:destroy, Account) }

      # Versions
      it { is_expected.not_to be_able_to(:read, PaperTrail::Version) }
    end
  end
end
