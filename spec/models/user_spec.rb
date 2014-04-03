require 'spec_helper'

describe User do
  include OmniauthHelpers

  describe 'factories' do
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

  describe 'validations' do
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
      it 'creates a new developer account on save' do
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
      it 'creates a new developer account on save' do
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
      it 'creates a new developer account on save' do
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
      it 'creates a new developer account on save' do
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
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        expect(user.has_provider_account?('google_oauth2')).to be_true
      end
    end
  end

  describe '#has_provider_account?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      expect(subject.has_provider_account?('facebook')).to be_false 
      expect(subject.has_provider_account?('twitter')).to be_false 
      expect(subject.has_provider_account?('github')).to be_false 
      expect(subject.has_provider_account?('google_oauth2')).to be_false 
    end
    context 'with a Facebook account' do
      before(:each) { FactoryGirl.create(:facebook_account, user: subject) }
      it 'returns true for facebook' do
        expect(subject.has_provider_account?('facebook')).to be_true
      end
    end
    context 'with a Twitter account' do
      before(:each) { FactoryGirl.create(:twitter_account, user: subject) }
      it 'returns true for twitter' do
        expect(subject.has_provider_account?('twitter')).to be_true
      end
    end
    context 'with a GitHub account' do
      before(:each) { FactoryGirl.create(:github_account, user: subject) }
      it 'returns true for github' do
        expect(subject.has_provider_account?('github')).to be_true
      end
    end
    context 'with a Google account' do
      before(:each) { FactoryGirl.create(:google_account, user: subject) }
      it 'returns true for google_oauth2' do
        expect(subject.has_provider_account?('google_oauth2')).to be_true
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

  describe '#profile_picture' do
    it 'returns the primary account image' do
      account_image = 'http://graph.facebook.com/1234567/picture?type=square'
      account = FactoryGirl.build_stubbed(:account)
      allow(account).to receive(:profile_picture).and_return(account_image)

      allow(subject).to receive(:primary_account).and_return(account)
      expect(subject.profile_picture).to be(account_image)
    end
    it 'reverts back to a gravatar image unique to email' do
      subject.email = 'bemo56@hotmail.com'
       # Gravatar hash of bemo56@hotmail.com
      expect(subject.profile_picture).to eq('http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128')
    end
  end

end
