# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  provider         :string(255)      not null
#  uid              :string(255)      not null
#  name             :string(255)
#  nickname         :string(255)
#  image            :string(255)
#  website          :string(255)
#  oauth_token      :string(255)
#  oauth_secret     :string(255)
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#

require 'spec_helper'

describe Account do
  include OmniauthHelpers

  describe 'associations' do
    it { should belong_to(:user).touch }
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
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          expect(existing_account).to receive(:update_from_auth_hash).with(auth_hash)
          expect(existing_account).to receive(:save)
          allow(Account).to receive(:find_by_provider_and_uid).and_return(existing_account)
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        expect(Account.find_for_oauth(auth_hash)).to be_nil
      end
    end
    context 'with a Twitter auth hash' do
      let(:auth_hash) { twitter_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:twitter_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          expect(existing_account).to receive(:update_from_auth_hash).with(auth_hash)
          expect(existing_account).to receive(:save)
          allow(Account).to receive(:find_by_provider_and_uid).and_return(existing_account)
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        expect(Account.find_for_oauth(auth_hash)).to be_nil
      end
    end
    context 'with a GitHub auth hash' do
      let(:auth_hash) { github_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:github_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          expect(existing_account).to receive(:update_from_auth_hash).with(auth_hash)
          expect(existing_account).to receive(:save)
          allow(Account).to receive(:find_by_provider_and_uid).and_return(existing_account)
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        expect(Account.find_for_oauth(auth_hash)).to be_nil
      end
    end
    context 'with a Google auth hash' do
      let(:auth_hash) { google_oauth2_hash }
      context 'with an existing account' do
        let!(:existing_account) { FactoryGirl.create(:google_oauth2_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          expect(existing_account).to receive(:update_from_auth_hash).with(auth_hash)
          expect(existing_account).to receive(:save)
          allow(Account).to receive(:find_by_provider_and_uid).and_return(existing_account)
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        expect(Account.find_for_oauth(auth_hash)).to be_nil
      end
    end
    it 'raises an exception if the provider does not match the expected value' do
      expect {
        Account.find_for_oauth(twitter_auth_hash, 'not_matching_provider')
      }.to raise_error(Exception, "Provider (twitter) doesn't match expected value: not_matching_provider")
    end
  end

  describe '.new_with_auth_hash' do
    it 'builds a new Account from a auth hash' do
      account = Account.new_with_auth_hash(twitter_auth_hash)
      expect(account).to_not be_persisted

      expect(account.name).to eq(twitter_auth_hash['info']['name'])
      expect(account.provider).to eq(twitter_auth_hash.provider)
    end
    it 'invokes #update_from_auth_hash on the new Account' do
      expect_any_instance_of(Account).to receive(:update_from_auth_hash)

      Account.new_with_auth_hash(twitter_auth_hash)
    end
    it 'raises an exception if the provider does not match the expected value' do
      expect {
        Account.new_with_auth_hash(twitter_auth_hash, 'not_matching_provider')
      }.to raise_error(Exception, "Provider (twitter) doesn't match expected value: not_matching_provider")
    end
  end

  describe '.omniauth_providers' do
    it { expect(Account.omniauth_providers).to include(:facebook) }
    it { expect(Account.omniauth_providers).to include(:twitter) }
    it { expect(Account.omniauth_providers).to include(:github) }
    it { expect(Account.omniauth_providers).to include(:google_oauth2) }
    it { expect(Account.omniauth_providers).not_to include(:developer) }
  end

  describe '#account_uid' do
    describe 'with a Facebook account' do
      subject { FactoryGirl.build_stubbed(:facebook_account) }
      it 'returns the name for Facebook' do
        subject.name = 'Test User'
        expect(subject.account_uid).to eq('Test User')
      end
    end
    describe 'with a Twitter account' do
      subject { FactoryGirl.build_stubbed(:twitter_account) }
      it 'returns the nickname for Twitter' do
        subject.nickname = '@testuser'
        expect(subject.account_uid).to eq('@testuser')
      end
      it 'prepends an @ to the nickname' do
        subject.nickname = 'testuser'
        expect(subject.account_uid).to eq('@testuser')
      end
    end
    describe 'with a GitHub account' do
      subject { FactoryGirl.build_stubbed(:github_account) }
      it 'returns the name for GitHub' do
        subject.nickname = 'testuser'
        expect(subject.account_uid).to eq('testuser')
      end
    end
    describe 'with a Google account' do
      subject { FactoryGirl.build_stubbed(:google_oauth2_account) }
      it 'returns the name for Google' do
        subject.name = 'Test User'
        expect(subject.account_uid).to eq('Test User')
      end
    end
  end

  describe '#enabled?' do
    it 'should be true for a valid account' do
      expect(FactoryGirl.build_stubbed(:account)).to be_enabled
    end
    it 'returns false for an account without a user' do
      expect(FactoryGirl.build_stubbed(:account, user: nil)).not_to be_enabled
    end
  end

  describe '#profile_picture' do
    it 'returns the image' do
      fake_image = Object.new
      expect(subject).to receive(:image).and_return(fake_image)
      expect(subject.profile_picture).to be(fake_image)
    end
  end

  describe '#provider_name' do
    it 'should return Developer for developer account' do
      account = FactoryGirl.create(:developer_account)
      expect(account.provider_name).to eq('Developer')
    end
    it 'should return Facebook for facebook account' do
      account = FactoryGirl.create(:facebook_account)
      expect(account.provider_name).to eq('Facebook')
    end
    it 'should return Twitter for twitter account' do
      account = FactoryGirl.create(:twitter_account)
      expect(account.provider_name).to eq('Twitter')
    end
    it 'should return GitHub for github account' do
      account = FactoryGirl.create(:github_account)
      expect(account.provider_name).to eq('GitHub')
    end
    it 'should return Google for google_auth2 account' do
      account = FactoryGirl.create(:google_oauth2_account)
      expect(account.provider_name).to eq('Google')
    end
  end

  describe '#remove_oauth_credentials' do
    context 'with an account with oauth credentials' do
      subject do
        FactoryGirl.build_stubbed(:account,
          oauth_token: 'oauth_token',
          oauth_secret: 'oauth_secret',
          oauth_expires_at: DateTime.now
        )
      end
      it 'sets oauth_token to nil' do
        subject.remove_oauth_credentials
        expect(subject.oauth_token).to be_nil
      end
      it 'sets oauth_secret to nil' do
        subject.remove_oauth_credentials
        expect(subject.oauth_secret).to be_nil
      end
      it 'sets oauth_expires_at to nil' do
        subject.remove_oauth_credentials
        expect(subject.oauth_expires_at).to be_nil
      end
    end
  end

  describe '#update_from_auth_hash' do
    context 'with a generic auth hash containing info params' do
      let(:info_params) { {} }
      let(:auth_hash) { OmniAuth::AuthHash.new({info: info_params}) }
      it 'should update the name from the auth hash' do
        info_params[:name] = 'Test User'
        subject.update_from_auth_hash(auth_hash)
        expect(subject.name).to eq('Test User')
      end
      it 'should update the nickname from the auth hash' do
        info_params[:nickname] = 'nickname'
        subject.update_from_auth_hash(auth_hash)
        expect(subject.nickname).to eq('nickname')
      end
      it 'should update the image from the auth hash' do
        info_params[:image] = 'http://graph.facebook.com/1234567/picture?type=square'
        subject.update_from_auth_hash(auth_hash)
        expect(subject.image).to eq('http://graph.facebook.com/1234567/picture?type=square')
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
        expect(subject.website).to eq(website)
      end
      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.update_from_auth_hash(auth_hash)

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_expires_at.to_s).to eq(expires.to_s)
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
        expect(subject.website).to eq(website)
      end
      it 'should set the oauth_token and oauth_secret values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:secret] = 'example_secret'
        subject.update_from_auth_hash(auth_hash)

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_secret).to eq('example_secret')
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
        expect(subject.website).to eq(website)
      end
      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.update_from_auth_hash(auth_hash)

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_expires_at.to_s).to eq(expires.to_s)
      end
      it 'should set the oauth_token and oauth_secret values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:secret] = 'example_secret'
        subject.update_from_auth_hash(auth_hash)

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_secret).to eq('example_secret')
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

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_expires_at.to_s).to eq(expires.to_s)
      end
    end
  end

end
