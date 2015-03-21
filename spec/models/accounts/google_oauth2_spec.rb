# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string           not null
#  name             :string
#  nickname         :string
#  image            :string
#  website          :string
#  oauth_token      :string
#  oauth_secret     :string
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string
#  deleted_at       :datetime
#
# Indexes
#
#  index_accounts_on_deleted_at  (deleted_at)
#  index_accounts_on_user_id     (user_id)
#

require 'rails_helper'

describe Account, type: :model do
  describe '.find_for_oauth' do
    context 'with a Google auth hash' do
      let(:auth_hash) { create :google_oauth2_auth_hash }
      context 'with an existing account' do
        let!(:existing_account) { create(:google_oauth2_account, uid: auth_hash.uid) }
        it 'finds the existing_account matching the uid' do
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
        it 'updates the existing account with the auth hash' do
          expect(existing_account).to receive(:update_from_auth_hash).with(auth_hash)
          expect(existing_account).to receive(:save)

          allow(Accounts::GoogleOauth2).to receive(:find_by_uid).and_return(existing_account)
          expect(Account.find_for_oauth(auth_hash)).to eq(existing_account)
        end
      end
      it 'returns nil with no existing Account' do
        expect(Account.find_for_oauth(auth_hash)).to be_nil
      end
    end
  end

  describe '.new_with_auth_hash' do
    context 'with a Google auth hash' do
      let(:auth_hash) { create :google_oauth2_auth_hash }

      it 'builds a new Accounts::GoogleOauth2 from a auth hash' do
        account = Account.new_with_auth_hash(auth_hash)
        expect(account).to be_kind_of(Accounts::GoogleOauth2)
        expect(account).to_not be_persisted
      end
      it 'invokes #update_from_auth_hash on the new Account' do
        expect_any_instance_of(Accounts::GoogleOauth2).to receive(:update_from_auth_hash)

        Account.new_with_auth_hash(auth_hash)
      end
    end
  end
end

describe Accounts::GoogleOauth2, type: :model do

  describe 'validations' do
    it { is_expected.to allow_value('Accounts::GoogleOauth2').for(:type) }
  end

  describe '#account_uid' do
    it 'returns the name' do
      subject.name = 'Test User'
      expect(subject.account_uid).to eq('Test User')
    end
    it 'falls back to uid' do
      subject.name = ''
      subject.uid = 'example_uid'
      expect(subject.account_uid).to eq('example_uid')
    end
  end

  describe '#enabled?' do
    context 'with a user account' do
      before(:each) { subject.user = build_stubbed(:user) }
      it { is_expected.to be_enabled }
    end
    context 'without a user' do
      it { is_expected.not_to be_enabled }
    end
  end

  describe '#provider_name' do
    it 'should return Google' do
      expect(subject.provider_name).to eq('Google')
    end
  end

  describe '#update_from_auth_hash' do
    context 'with a generic auth hash containing info params' do
      let(:info_params) do
        {
          name: 'Test User',
          email: 'test@example.com',
          nickname: 'nickname',
          image: 'http://graph.facebook.com/1234567/picture?type=square'
        }
      end
      let(:auth_hash) { OmniAuth::AuthHash.new(info: info_params) }
      it 'should update the name from the auth hash' do
        subject.send(:update_from_auth_hash, auth_hash)
        expect(subject.name).to eq('Test User')
      end
      it 'should update the email from the auth hash' do
        subject.send(:update_from_auth_hash, auth_hash)
        expect(subject.email).to eq('test@example.com')
      end
      it 'should update the nickname from the auth hash' do
        subject.send(:update_from_auth_hash, auth_hash)
        expect(subject.nickname).to eq('nickname')
      end
      it 'should update the image from the auth hash' do
        subject.send(:update_from_auth_hash, auth_hash)
        expect(subject.image).to eq('http://graph.facebook.com/1234567/picture?type=square')
      end
    end
    context 'with a Google auth hash' do
      let(:info_params) { {} }
      let(:credentials_params) { {} }
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          info: info_params,
          credentials: credentials_params
        )
      end

      it 'should set the oauth_token and oauth_expires values' do
        expires = 3.months.since
        credentials_params[:token] = 'example_token'
        credentials_params[:expires_at] = expires.to_i
        subject.send(:update_from_auth_hash, auth_hash)

        expect(subject.oauth_token).to eq('example_token')
        expect(subject.oauth_expires_at.to_s).to eq(expires.to_s)
      end
    end
  end
end
