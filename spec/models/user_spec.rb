# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  name                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

require 'spec_helper'

describe User do
  include OmniauthHelpers

  describe 'Factories' do
    it 'creates a User with basic details' do
      user = FactoryGirl.create(:user)
      expect(user.name).not_to be_blank
      expect(user.email).not_to be_blank
      expect(user.encrypted_password).not_to be_nil
    end
    describe 'role traits' do
      it 'creates a admin user' do
        user = FactoryGirl.create(:user, :admin)
        expect(user).to have_role(:admin)
      end
      it 'creates a banned user' do
        user = FactoryGirl.create(:user, :banned)
        expect(user).to have_role(:banned)
      end
    end
  end

  describe 'Associations' do
    it { should have_many(:accounts).dependent(:destroy) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_acceptance_of(:terms_and_conditions) }
  end

  describe '.new_with_session' do
    Account.omniauth_providers.each do |provider|
      provider_name = Account.provider_name(provider)

      context "with #{provider_name} auth_session_data" do
        let(:session) { { "devise.#{provider}_data" => provider_auth_hash(provider) } }
        it 'builds a new user using values from the auth hash' do
          user = User.new_with_session({}, session)
          expect(user.name).to eq(auth_account[:name])
          expect(user.email).to eq(auth_account[:email]) unless provider == :twitter
        end
        context 'with valid user params' do
          let(:user_params) { FactoryGirl.attributes_for(:user) }

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

            expect(Account.last.provider).to eq provider.to_s
          end
        end
        context 'with invalid account data' do
          let(:user) do
            user_params = FactoryGirl.attributes_for(:user)
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
            user_params = FactoryGirl.attributes_for(:user)
            user = User.new_with_session(user_params, session)
            user.save

            expected = "Unable to add your #{provider_name} account"
            expect(user.errors.messages[:base]).to include expected
          end
        end
      end
    end
  end

  describe '#provider_account?' do
    subject { FactoryGirl.create(:user) }
    context 'with no Account' do
      Account::PROVIDERS.each do |provider|
        it "returns false for #{provider}" do
          subject.provider_account?(provider)
        end
      end
    end
    Account::PROVIDERS.each do |provider|
      context "with a #{provider} account" do
        let!(:account) { FactoryGirl.create :"#{provider}_account", user: subject }
        it "returns true for #{provider}" do
          expect(subject.provider_account? provider).to be(true)
        end
        Account::PROVIDERS.reject { |p| p == provider }.each do |p|
          it "returns false for #{p}" do
            expect(subject.provider_account? p).to be(false)
          end
        end
      end
    end
  end

  describe '#primary_account' do
    it 'returns the first account' do
      first_account = FactoryGirl.build_stubbed(:account)
      allow(subject).to receive(:accounts).and_return([
        first_account,
        FactoryGirl.build_stubbed(:account)
      ])
      expect(subject.primary_account).to be(first_account)
    end
  end

  # Instance Methods (Pictures)

  describe '#gravatar_image' do
    context 'with a email address' do
      before(:each) { subject.email = 'bemo56@hotmail.com' }
      context 'with no arguments' do
        it 'returns a 128px gravatar image url' do
          expected = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
          expect(subject.gravatar_image).to eq(expected)
        end
      end
      %w(16 32 64 128).each do |size|
        context "with a size argument of #{size}" do
          it "returns a #{size}px gravatar image url" do
            expected = "http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=#{size}"
            expect(subject.gravatar_image(size)).to eq(expected)
          end
        end
      end
    end
    context 'with no email address' do
      it 'returns nil' do
        expect(subject.gravatar_image).to be_nil
      end
    end
  end

  describe '#profile_picture' do
    context 'with a primary account' do
      let(:account) { FactoryGirl.build_stubbed(:account) }
      before(:each) do
        # Stub the primary_account method
        allow(subject).to receive(:primary_account).and_return(account)
      end
      context 'with a profile_picture' do
        let(:account_image) { 'http://graph.facebook.com/1234567/picture?type=square' }
        before(:each) { allow(account).to receive(:profile_picture).and_return(account_image) }

        it 'returns the profile_picture from the primary account ' do
          expect(subject.profile_picture).to be(account_image)
        end
      end
      context 'without a profile picture' do
        before(:each) { allow(account).to receive(:profile_picture).and_return(nil) }

        it 'reverts back to the gravatar image' do
          gravatar_image = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
          allow(subject).to receive(:gravatar_image).and_return(gravatar_image)

          expect(subject.profile_picture).to eq(gravatar_image)
        end
      end
    end
    context 'with no accounts' do
      it 'returns the gravatar image for the user' do
        gravatar_image = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
        allow(subject).to receive(:gravatar_image).and_return(gravatar_image)

        expect(subject.profile_picture).to eq(gravatar_image)
      end
    end
  end

end
