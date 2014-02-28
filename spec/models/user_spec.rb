require 'spec_helper'

describe User do
  include OmniauthHelpers

  describe 'factories' do
    it 'creates a User with basic details' do
      user = FactoryGirl.create(:user)
      user.name.should_not be_blank
      user.email.should_not be_blank
      user.encrypted_password.should_not be_nil
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
        user.name.should eq(auth_account[:name])
        user.email.should eq(auth_account[:email])
      end
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        user.has_provider_account?('developer').should be_true
      end
    end
    context 'with Facebook auth session data' do
      let(:session) {{ 'devise.facebook_data' => facebook_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        user.name.should eq(facebook_credentials[:name])
        user.email.should eq(auth_account[:email])
      end
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        user.has_provider_account?('facebook').should be_true
      end
    end
    context 'with Twitter auth session data' do
      let(:session) {{ 'devise.twitter_data' => twitter_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        user.name.should eq(twitter_credentials[:name])
        user.email.should be_nil # Twitter doesn't include email
      end
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        user.has_provider_account?('twitter').should be_true
      end
    end
    context 'with GitHub auth session data' do
      let(:session) {{ 'devise.github_data' => github_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        user.name.should eq(github_credentials[:name])
        user.email.should eq(auth_account[:email])
      end
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        user.has_provider_account?('github').should be_true
      end
    end
    context 'with Google auth session data' do
      let(:session) {{ 'devise.google_oauth2_data' => google_auth_hash }}
      it 'builds a new user using values from the auth hash' do
        user = User.new_with_session({}, session)
        user.name.should eq(google_credentials[:name])
        user.email.should eq(auth_account[:email])
      end
      it 'creates a new developer account on save' do
        user_params = FactoryGirl.attributes_for(:user)
        user = User.new_with_session(user_params, session)
        user.save!
        user.has_provider_account?('google_oauth2').should be_true
      end
    end
  end

  describe '#has_provider_account?' do
    subject { FactoryGirl.create(:user) }
    it 'returns false with no accounts' do
      subject.has_provider_account?('facebook').should be_false 
      subject.has_provider_account?('twitter').should be_false 
      subject.has_provider_account?('github').should be_false 
      subject.has_provider_account?('google_oauth2').should be_false 
    end
    context 'with a Facebook account' do
      before(:each) { FactoryGirl.create(:facebook_account, user: subject) }
      it 'returns true for facebook' do
        subject.has_provider_account?('facebook').should be_true
      end
    end
    context 'with a Twitter account' do
      before(:each) { FactoryGirl.create(:twitter_account, user: subject) }
      it 'returns true for twitter' do
        subject.has_provider_account?('twitter').should be_true
      end
    end
    context 'with a GitHub account' do
      before(:each) { FactoryGirl.create(:github_account, user: subject) }
      it 'returns true for github' do
        subject.has_provider_account?('github').should be_true
      end
    end
    context 'with a Google account' do
      before(:each) { FactoryGirl.create(:google_account, user: subject) }
      it 'returns true for google_oauth2' do
        subject.has_provider_account?('google_oauth2').should be_true
      end
    end
  end

  describe '#primary_account' do
    it 'returns the first account' do
      first_account = FactoryGirl.build_stubbed(:account)
      subject.stub(:accounts).and_return([first_account, FactoryGirl.build_stubbed(:account)])
      subject.primary_account.should be(first_account)
    end
  end

  describe '#profile_picture' do
    it 'returns the primary account image' do
      account_image = 'http://graph.facebook.com/1234567/picture?type=square'
      account = FactoryGirl.build_stubbed(:account)
      account.stub(:profile_picture).and_return(account_image)

      subject.stub(:primary_account).and_return(account)
      subject.profile_picture.should be(account_image)
    end
    it 'reverts back to a gravatar image unique to email' do
      subject.email = 'bemo56@hotmail.com'
       # Gravatar hash of bemo56@hotmail.com
      subject.profile_picture.should eq('http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128')
    end
  end

end
