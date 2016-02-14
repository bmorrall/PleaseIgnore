require 'rails_helper'

describe Users::ArchiveExpiredUser do
  subject(:instance) { described_class.new(user) }

  describe '#call' do
    subject { instance.call }

    context 'with a safe to strip user' do
      let(:user) { create(:user, :confirmed, :expired, email: Faker::Internet.email) }

      it 'should strip the user account details' do
        expect do
          subject
          user.reload
        end.to change(user, :email).to(nil)
        expect(user.confirmed_at).to eq nil
      end
    end
    context 'with a safe to strip user with an account' do
      let!(:user) { create(:user, :expired, :with_auth_hash, email: Faker::Internet.email) }

      it 'should remove any associated accounts' do
        expect { subject }.to change(Account, :count).by(-1)
      end
    end
  end

  describe '#safe_to_strip?' do
    let(:user) { instance_double('User', email?: true, expired?: true) }
    subject { described_class.new(user).safe_to_strip? }

    context 'when the user is expired and still has an email' do
      let(:user) { instance_double('User', email?: true, expired?: true) }
      it { should be true }
    end

    context 'when the user is expired and has an account' do
      let(:user) do
        instance_double('User', email?: false, expired?: true, accounts: [double('account')])
      end
      it { should be true }
    end

    context 'when the user has an empty email and no accounts' do
      before do
        allow(user).to receive(:email?).and_return(false)
        allow(user).to receive(:accounts).and_return([])
      end
      it { should be false }
    end

    context 'when the user is not expired' do
      before { allow(user).to receive(:expired?).and_return(false) }
      it { should be false }
    end
  end
end
