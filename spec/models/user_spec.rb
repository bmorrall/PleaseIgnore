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
  end

  describe 'Associations' do
    it { should have_many(:accounts).dependent(:destroy) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_acceptance_of(:terms_and_conditions) }
  end

  describe '.new_with_session' do
    context 'with developer auth session data' do
      let(:session) {{ 'devise.developer_data' => developer_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        expect(user.name).to eq(auth_account[:name])
        expect(user.email).to eq(auth_account[:email])
      end
      it 'creates a new Developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('developer')).to be_true
      end
    end
    context 'with Facebook auth session data' do
      let(:session) {{ 'devise.facebook_data' => facebook_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        expect(user.name).to eq(facebook_credentials[:name])
        expect(user.email).to eq(auth_account[:email])
      end
      it 'creates a new Facebook account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('facebook')).to be_true
      end
    end
    context 'with Twitter auth session data' do
      let(:session) {{ 'devise.twitter_data' => twitter_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        expect(user.name).to eq(twitter_credentials[:name])
        expect(user.email).to be_nil # Twitter doesn't include email
      end
      it 'creates a new Twitter account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('twitter')).to be_true
      end
    end
    context 'with GitHub auth session data' do
      let(:session) {{ 'devise.github_data' => github_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        expect(user.name).to eq(github_credentials[:name])
        expect(user.email).to eq(auth_account[:email])
      end
      it 'creates a new GitHub account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('github')).to be_true
      end
    end
    context 'with Google auth session data' do
      let(:session) {{ 'devise.google_oauth2_data' => google_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        expect(user.name).to eq(google_credentials[:name])
        expect(user.email).to eq(auth_account[:email])
      end
      it 'creates a new Google account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('google_oauth2')).to be_true
      end
    end
  end

  describe '#has_provider_account?' do
    subject { FactoryGirl.create(:user) }
    context 'with no Account' do
      Account::PROVIDERS.each do |provider|
        it "returns false for #{provider}" do
          subject.has_provider_account?(provider)
        end
      end
    end
    Account::PROVIDERS.each do |provider|
      context "with a #{Account.provider_name(provider)} Account" do
        let!(:account) { FactoryGirl.create :"#{provider}_account", user: subject }
        it "returns true for #{provider}" do
          expect(subject.has_provider_account? provider).to be_true
        end
        Account::PROVIDERS.reject { |p| p == provider }.each do |p|
          it "returns false for #{p}" do
            expect(subject.has_provider_account? p).to be_false
          end
        end
      end
    end
  end

  describe '#primary_account' do
    it 'returns the first account' do
      first_account = FactoryGirl.build_stubbed(:account)
      allow(subject).to receive(:accounts).and_return([first_account, FactoryGirl.build_stubbed(:account)])
      expect(subject.primary_account).to be(first_account)
    end
  end

  # Instance Methods (Pictures)

  describe '#gravatar_image' do
    context 'with a email address' do
      before(:each) { subject.email = 'bemo56@hotmail.com' }
      context 'with no arguments' do
        it 'returns a 128px gravatar image url' do
          expect(subject.gravatar_image).to eq('http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128')
        end
      end
      %w(16 32 64 128).each do |size|
        context "with a size argument of #{size}" do
          it "returns a #{size}px gravatar image url" do
            expect(subject.gravatar_image(size)).to eq("http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=#{size}")
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
