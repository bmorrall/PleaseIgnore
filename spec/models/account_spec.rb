require 'spec_helper'

describe Account do
  include OmniauthHelpers

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:uid) }
    it 'should validate uniqueness of uid scoped to provider' do
      FactoryGirl.create(:account)
      should validate_uniqueness_of(:uid).scoped_to(:provider)
    end
    it { should validate_presence_of(:user_id) }

    it { should allow_value('developer').for(:provider) }
    it { should allow_value('facebook').for(:provider) }
    it { should allow_value('github').for(:provider) }
    it { should allow_value('google_oauth2').for(:provider) }
    it { should allow_value('twitter').for(:provider) }
  end

  describe '.find_for_oauth' do
    context 'with a Facebook auth hash' do
      let(:auth_hash) { facebook_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:facebook_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          existing_account.should_receive(:update_from_auth_hash).with(auth_hash)
          existing_account.should_receive(:save)
          Account.stub(:find_by_provider_and_uid).and_return(existing_account)
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        Account.find_for_oauth(auth_hash).should be_nil
      end
    end
    context 'with a Twitter auth hash' do
      let(:auth_hash) { twitter_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:twitter_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          existing_account.should_receive(:update_from_auth_hash).with(auth_hash)
          existing_account.should_receive(:save)
          Account.stub(:find_by_provider_and_uid).and_return(existing_account)
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        Account.find_for_oauth(auth_hash).should be_nil
      end
    end
    context 'with a GitHub auth hash' do
      let(:auth_hash) { github_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:github_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          existing_account.should_receive(:update_from_auth_hash).with(auth_hash)
          existing_account.should_receive(:save)
          Account.stub(:find_by_provider_and_uid).and_return(existing_account)
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        Account.find_for_oauth(auth_hash).should be_nil
      end
    end
    context 'with a Google auth hash' do
      let(:auth_hash) { google_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:google_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          existing_account.should_receive(:update_from_auth_hash).with(auth_hash)
          existing_account.should_receive(:save)
          Account.stub(:find_by_provider_and_uid).and_return(existing_account)
          Account.find_for_oauth(auth_hash).should eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        Account.find_for_oauth(auth_hash).should be_nil
      end
    end
    it 'raises an exception if the provider does not match the expected value' do
      expect {
        Account.find_for_oauth(twitter_auth_hash, 'not_matching_provider')
      }.to raise_error(Exception, "Provider (twitter) doesn't match expected value: not_matching_provider")
    end
  end

  describe '.omniauth_providers' do
    it { Account.omniauth_providers.should include(:facebook) }
    it { Account.omniauth_providers.should include(:twitter) }
    it { Account.omniauth_providers.should include(:github) }
    it { Account.omniauth_providers.should include(:google_oauth2) }
    it { Account.omniauth_providers.should_not include(:developer) }
  end

  describe '.provider_name' do
    it 'should return Developer for developer' do
      Account.provider_name('developer').should eq('Developer')
    end
    it 'should return Facebook for facebook' do
      Account.provider_name('facebook').should eq('Facebook')
    end
    it 'should return Twitter for twitter' do
      Account.provider_name('twitter').should eq('Twitter')
    end
    it 'should return GitHub for github' do
      Account.provider_name('github').should eq('GitHub')
    end
    it 'should return Google for google_auth2' do
      Account.provider_name('google_oauth2').should eq('Google')
    end
  end

  describe '#account_uid' do
    describe 'with a Facebook account' do
      subject { FactoryGirl.build_stubbed(:facebook_account) }
      it 'returns the name for Facebook' do
        subject.name = 'Test User'
        subject.account_uid.should eq('Test User')
      end
    end
    describe 'with a Twitter account' do
      subject { FactoryGirl.build_stubbed(:twitter_account) }
      it 'returns the nickname for Twitter' do
        subject.nickname = '@testuser'
        subject.account_uid.should eq('@testuser')
      end
      it 'prepends an @ to the nickname' do
        subject.nickname = 'testuser'
        subject.account_uid.should eq('@testuser')
      end
    end
    describe 'with a GitHub account' do
      subject { FactoryGirl.build_stubbed(:github_account) }
      it 'returns the name for GitHub' do
        subject.nickname = 'testuser'
        subject.account_uid.should eq('testuser')
      end
    end
    describe 'with a Google account' do
      subject { FactoryGirl.build_stubbed(:google_account) }
      it 'returns the name for Google' do
        subject.name = 'Test User'
        subject.account_uid.should eq('Test User')
      end
    end
  end

  describe '#enabled?' do
    it 'should be true for a valid account' do
      FactoryGirl.build_stubbed(:account).should be_enabled
    end
    it 'returns false for an account without a user' do
      FactoryGirl.build_stubbed(:account, user: nil).should_not be_enabled
    end
  end

  describe '#profile_picture' do
    it 'returns the image' do
      fake_image = Object.new
      subject.should_receive(:image).and_return(fake_image)
      subject.profile_picture.should be(fake_image)
    end
  end

  describe '#provider_name' do
    it 'returns Account.provider_name with the provider' do
      fake_provider = 'provider'
      fake_provider_name = 'ProVid3r'
      subject.provider = fake_provider
      Account.should_receive(:provider_name).with(fake_provider).and_return(fake_provider_name)
      subject.provider_name.should be(fake_provider_name)
    end
  end

  describe '#update_from_auth_hash' do
    context 'with a generic auth hash containing info params' do
      let(:info_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({info: info_params}) }
      it 'should update the name from the auth hash' do
        info_params[:name] = 'Test User'
        subject.update_from_auth_hash(auth_hash)
        subject.name.should eq('Test User')
      end
      it 'should update the nickname from the auth hash' do
        info_params[:nickname] = 'nickname'
        subject.update_from_auth_hash(auth_hash)
        subject.nickname.should eq('nickname')
      end
      it 'should update the image from the auth hash' do
        info_params[:image] = 'http://graph.facebook.com/1234567/picture?type=square'
        subject.update_from_auth_hash(auth_hash)
        subject.image.should eq('http://graph.facebook.com/1234567/picture?type=square')
      end
    end
    context 'with a Facebook account' do
      before(:each) { subject.provider = 'facebook' }
      let(:info_params) { {} }
      let(:credentials_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({provider: 'facebook', info: info_params, credentials: credentials_params}) }

      it 'should set the website from the Facebook url' do
        website = 'http://www.facebook.com/jbloggs'
        info_params[:urls] = { Facebook: website }
        subject.update_from_auth_hash(auth_hash)
        subject.website.should eq(website)
      end
      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.update_from_auth_hash(auth_hash)

        subject.oauth_token.should eq('example_token')
        subject.oauth_expires_at.to_s.should eq(expires.to_s)
      end
    end
    context 'with a Twitter auth hash' do
      before(:each) { subject.provider = 'twitter' }
      let(:info_params) { {} }
      let(:credentials_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({provider: 'twitter', info: info_params, credentials: credentials_params}) }

      it 'should set the website from the Facebook url' do
        website = 'https://twitter.com/johnqpublic'
        info_params[:urls] = { Twitter: website }
        subject.update_from_auth_hash(auth_hash)
        subject.website.should eq(website)
      end
      it 'should set the oauth_token and oauth_secret values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:secret] = 'example_secret'
        subject.update_from_auth_hash(auth_hash)

        subject.oauth_token.should eq('example_token')
        subject.oauth_secret.should eq('example_secret')
      end
    end
    context 'with a GitHub auth hash' do
      before(:each) { subject.provider = 'github' }
      let(:info_params) { {} }
      let(:credentials_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({provider: 'github', info: info_params, credentials: credentials_params}) }

      it 'should set the website from the Facebook url' do
        website = 'https://github.com/johnqpublic'
        info_params[:urls] = { Github: website }
        subject.update_from_auth_hash(auth_hash)
        subject.website.should eq(website)
      end
      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.update_from_auth_hash(auth_hash)

        subject.oauth_token.should eq('example_token')
        subject.oauth_expires_at.to_s.should eq(expires.to_s)
      end
      it 'should set the oauth_token and oauth_secret values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:secret] = 'example_secret'
        subject.update_from_auth_hash(auth_hash)

        subject.oauth_token.should eq('example_token')
        subject.oauth_secret.should eq('example_secret')
      end
    end
    context 'with a Google auth hash' do
      before(:each) { subject.provider = 'google_oauth2' }
      let(:info_params) { {} }
      let(:credentials_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({provider: 'google_oauth2', info: info_params, credentials: credentials_params}) }

      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.update_from_auth_hash(auth_hash)

        subject.oauth_token.should eq('example_token')
        subject.oauth_expires_at.to_s.should eq(expires.to_s)
      end
    end
  end

end
