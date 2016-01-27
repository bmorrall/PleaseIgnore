require 'rails_helper'

describe Concerns::Users::DeviseAccountAuthentication do
  class DeviseAccountAuthenticationTestUser < ActiveRecord::Base
    devise(:database_authenticatable)
    include Concerns::Users::DeviseAccountAuthentication

    self.table_name = :users
  end
  subject(:instance) { DeviseAccountAuthenticationTestUser.new }

  describe 'Associations' do
    it { is_expected.to have_many(:accounts).dependent(:destroy) }
  end

  describe '.new_with_session' do
    Account.omniauth_providers.each do |provider|
      provider_name = Account.provider_name(provider)

      context "with #{provider_name} auth_session_data" do
        let(:auth_hash) { create :"#{provider}_auth_hash" }
        let(:session) { { "devise.#{provider}_data" => auth_hash } }
        it 'builds a new user using values from the auth hash' do
          user = User.new_with_session({}, session)
          expect(user.name).to eq(auth_hash.info.name)
          expect(user.email).to eq(auth_hash.info.email) unless provider == :twitter
        end
        context 'with valid user params' do
          let(:user_params) { attributes_for(:user) }

          it 'builds a valid user' do
            user = User.new_with_session(user_params, session)
            expect(user).to be_valid
          end

          it 'populates #new_session_accounts with a new account' do
            user = User.new_with_session(user_params, session)
            new_sessions = user.new_session_accounts
            expect(new_sessions.count).to eq(1)
            expect(new_sessions.first).to be_kind_of(Account)
          end

          it "creates a new #{provider_name} account on save" do
            expect do
              user = User.new_with_session(user_params, session)
              user.save!
            end.to change(Account, :count).by(1)

            expect(Account.last.provider).to eq provider
          end
        end
        context 'with invalid account data' do
          let(:user) do
            user_params = attributes_for(:user)
            User.new_with_session(user_params, session)
          end
          before(:each) do
            expect_any_instance_of(Account).to receive(:valid?).and_return(false)
          end

          it 'does not create a new Account on save' do
            expect do
              user.save
            end.to_not change(Account, :count)
          end
          it 'does not create a new User on save' do
            expect do
              user.save
            end.to_not change(User, :count)
          end
          it 'adds an error to the User on save' do
            user_params = attributes_for(:user)
            user = User.new_with_session(user_params, session)
            user.save

            expected = "Unable to add your #{provider_name} account"
            expect(user.errors.messages[:base]).to include expected
          end
        end
      end
    end
  end

  describe '#password_required?' do
    subject { instance.password_required? }

    it 'returns true when password is set' do
      instance.password = Faker::Lorem.word
      is_expected.to be(true)
    end
    it 'returns true when password_confirmation is set' do
      instance.password_confirmation = Faker::Lorem.word
      is_expected.to be(true)
    end
    context 'with a new user' do
      context 'with a new session account' do
        before(:each) do
          allow(instance).to receive(:new_session_accounts).and_return([double(:account)])
        end
        it { is_expected.to be(false) }
      end
      context 'with no new session accounts' do
        before(:each) do
          allow(instance).to receive(:new_session_accounts).and_return([])
        end
        it { is_expected.to be(true) }
      end
    end
    context 'with a persisted user' do
      let(:instance) { create(:user).tap(&:reload) }

      context 'with a new session account' do
        before(:each) do
          allow(instance).to receive(:new_session_accounts).and_return([double(:account)])
        end
        it { is_expected.to be(true) }
      end
    end
  end

  describe '#primary_account' do
    it 'returns the first account' do
      first_account = build_stubbed(:developer_account)
      allow(subject).to receive(:accounts).and_return(
        [
          first_account,
          build_stubbed(:developer_account)
        ]
      )
      expect(subject.primary_account).to be(first_account)
    end
  end

  describe '#provider_account?' do
    subject { create(:user) }
    context 'with no Account' do
      Account::PROVIDERS.each do |provider|
        it "returns false for #{provider}" do
          subject.provider_account?(provider)
        end
      end
    end
    Account::PROVIDERS.each do |provider|
      context "with a #{provider} account" do
        let!(:account) { create :"#{provider}_account", user: subject }
        it "returns true for #{provider}" do
          expect(subject.provider_account?(provider)).to be(true)
        end
        Account::PROVIDERS.reject { |p| p == provider }.each do |other_provider|
          it "returns false for #{other_provider}" do
            expect(subject.provider_account?(other_provider)).to be(false)
          end
        end
      end
    end
  end

  describe '#update_with_password' do
    let(:attributes) { { password: 'test' } }
    subject { instance.update_with_password(attributes) }

    it 'should call update_attributes with a valid password' do
      expect(instance).to receive(:valid_password?).with(nil).and_return(true)
      expect(instance).to receive(:update_attributes)
      subject
    end
    it 'should call valid_password with allow_empty_password as true then return it to false' do
      expect(instance).to receive(:valid_password?) do
        expect(instance.send(:allow_empty_password?)).to be(true)
      end
      expect(instance).to receive(:update_attributes)
      subject
      expect(instance.send(:allow_empty_password?)).to be(false)
    end
  end

  describe '#valid_password?' do
    subject { instance.valid_password?(password) }

    context 'when the password is nil and the encrypted password is blank' do
      let(:password) { nil }

      it 'should return the result from allow_empty_password?' do
        result = double('result')
        allow(instance).to receive(:allow_empty_password?).and_return(result)
        expect(subject).to eq result
      end
    end
  end
end
