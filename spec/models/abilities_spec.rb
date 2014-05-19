require 'spec_helper'
require "cancan/matchers"

describe User do

  describe 'abilities' do
    let(:user) { nil }
    subject { Ability.new(user) }

    describe 'as a guest' do

      # Accounts
      it { should be_able_to(:create, Account) }

      # Contacts
      it { should be_able_to(:create, Contact) }
    end

    describe 'as a user' do
      let(:user) { FactoryGirl.build_stubbed(:user) }

      # Accounts
      it { should be_able_to(:create, Account) }
      it { should be_able_to(:update, FactoryGirl.build_stubbed(:account, user: user)) }
      it { should be_able_to(:destroy, FactoryGirl.build_stubbed(:account, user: user)) }
      it { should_not be_able_to(:update, FactoryGirl.build_stubbed(:account)) }
      it { should_not be_able_to(:destroy, FactoryGirl.build_stubbed(:account)) }

      # Contacts
      it { should be_able_to(:create, Contact) }
    end
  end
end