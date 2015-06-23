require 'rails_helper'

describe Accounts::AuthenticateWithAccount do
  describe '.call' do
    let(:auth_hash) { double(:auth_hash) }
    let(:provider) { Account::PROVIDERS.sample }
    subject { described_class.call auth_hash, provider }

    context 'when Account.find_for_oauth returns an enabled account' do
      let(:account) { double(Account, enabled?: true) }
      before(:each) do
        expect(Account).to receive(:find_for_oauth).with(auth_hash, provider).and_return(account)
      end

      its(:account) { should eq(account) }
      its(:success_message) do
        provider_name = Account.provider_name(provider)
        should eq(
          t('devise.omniauth_callbacks.success_authenticated', kind: provider_name)
        )
      end

      context 'with a persisted user' do
        let(:user) { build_stubbed(:user) }
        before(:each) { allow(account).to receive(:user).and_return(user) }

        its(:user_persisted?) { should eq(true) }
      end
      context 'with a new user' do
        before(:each) { allow(account).to receive(:user).and_return(User.new) }

        its(:user_persisted?) { should eq(false) }
      end
    end
    context 'when Account.find_for_oauth returns a disabled account' do
      let(:account) { double(Account, enabled?: false) }
      before(:each) do
        expect(Account).to receive(:find_for_oauth).with(auth_hash, provider).and_return(account)
      end

      it 'should raise a AccountDisabledError' do
        expect { subject }.to raise_error(Accounts::AuthenticateWithAccount::AccountDisabledError)
      end
    end
    context 'when Account.find_for_oauth does not find an account' do
      before(:each) do
        expect(Account).to receive(:find_for_oauth).with(auth_hash, provider).and_return(nil)
      end

      its(:success_message) do
        should eq(
          t('devise.omniauth_callbacks.success_registered', kind: Account.provider_name(provider))
        )
      end
      its(:user_persisted?) { should eq(false) }
    end
  end
end
