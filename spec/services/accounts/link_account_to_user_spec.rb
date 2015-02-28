require 'rails_helper'

describe Accounts::LinkAccountToUser do

  describe '.call' do
    let(:user) { double(:user) }
    let(:auth_hash) { double(:auth_hash) }
    let(:provider) { Account::PROVIDERS.sample }
    subject { described_class.call user, auth_hash, provider }

    context 'when Account.find_for_oauth returns an existing account' do
      let(:user) { build_stubbed(:user) }
      let(:account) { build_stubbed :account }
      before(:each) do
        expect(Account).to receive(:find_for_oauth).with(auth_hash, provider).and_return(account)
      end

      context 'when the account belongs to the user' do
        before(:each) { account.user = user }

        its(:account) { should eq(account) }
        its(:success_message) do
          should eq(
            t('devise.omniauth_callbacks.success_linked', kind: Account.provider_name(provider))
          )
        end
      end
      context 'when the account belongs to another user' do
        before(:each) { account.user = build_stubbed(:user) }

        it 'should raise a PreviouslyLinkedError' do
          provider_name = Account.provider_name(provider)
          error_message = t('account.reasons.failure.previously_linked', kind: provider_name)
          expect { subject }.to raise_error(described_class::PreviouslyLinkedError, error_message)
        end
      end
      context 'when the account has no user' do
        before(:each) { account.user = nil }

        it 'should raise a AccountDisabledError' do
          provider_name = Account.provider_name(provider)
          error_message = t('account.reasons.failure.account_disabled', kind: provider_name)
          expect { subject }.to raise_error(described_class::AccountDisabledError, error_message)
        end
      end
    end

    context 'when Account.find_for_oauth is unable to find a account' do
      before(:each) do
        expect(Account).to receive(:find_for_oauth).with(auth_hash, provider).and_return(nil)
      end

      context 'when the user already has a account with provider' do
        before(:each) do
          expect(user).to receive(:provider_account?).with(provider).and_return(true)
        end

        it 'should raise a AccountLimitError' do
          provider_name = Account.provider_name(provider)
          error_message = t('account.reasons.failure.account_limit', kind: provider_name)
          expect { subject }.to raise_error(described_class::AccountLimitError, error_message)
        end
      end

      context 'when a valid account can be created for the user' do
        let(:account) { double(Account, save: true) }
        before(:each) do
          expect(user).to receive(:provider_account?).with(provider).and_return(false)
          expect(user).to(
            receive_message_chain(:accounts, :new_with_auth_hash).with(auth_hash, provider)
                                                                 .and_return(account)
          )
        end

        its(:account) { should eq(account) }
        its(:success_message) do
          should eq(
            t('devise.omniauth_callbacks.success_linked', kind: Account.provider_name(provider))
          )
        end
      end
      context 'when the account is unable to be saved' do
        let(:account) { double(Account, save: false) }
        before(:each) do
          expect(user).to receive(:provider_account?).with(provider).and_return(false)
          expect(user).to(
            receive_message_chain(:accounts, :new_with_auth_hash).with(auth_hash, provider)
                                                                 .and_return(account)
          )
        end

        it 'should raise a AccountInvalidError' do
          provider_name = Account.provider_name(provider)
          error_message = t('account.reasons.failure.account_invalid', kind: provider_name)
          expect { subject }.to raise_error(described_class::AccountInvalidError, error_message)
        end
      end
    end
  end
end
