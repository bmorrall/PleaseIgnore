# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
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
#  type             :string(255)
#  deleted_at       :datetime
#

require 'spec_helper'

describe Account do
  include OmniauthHelpers

  it_behaves_like 'a soft deletable model'

  describe 'associations' do
    it { should belong_to(:user).touch }
  end

  describe 'validations' do
    it { should validate_presence_of(:uid) }
    it 'should validate uniqueness of uid scoped to provider' do
      create(:developer_account)
      should validate_uniqueness_of(:uid).scoped_to(:type)
    end

    it { should validate_presence_of(:user_id) }
    it 'should validate uniqueness of user_id scoped to provider' do
      create(:developer_account)
      should validate_uniqueness_of(:user_id).scoped_to(:type)
    end

    context 'with a existing soft deleted account' do
      let!(:account) { create(:developer_account, :soft_deleted) }
      # Ensure validate_uniqueness_of compares against soft deleted model
      before(:each) { expect(described_class).to receive(:first).and_return(account) }

      it { should_not validate_uniqueness_of(:uid).scoped_to(:type) }
      it { should_not validate_uniqueness_of(:user_id).scoped_to(:type) }
    end
  end

  describe 'versioning' do
    it 'creates a create version on create' do
      account = build :account
      with_versioning do
        expect do
          account.save!
        end.to change(PaperTrail::Version, :count).by(1)
      end
      expect(account.versions.last.event).to eq('create')
    end
    it 'creates a destroy version on delete' do
      account = create :account
      with_versioning do
        expect do
          account.destroy
        end.to change(PaperTrail::Version, :count).by(1)
      end
      expect(account.versions.last.event).to eq('destroy')
    end
    it 'creates a restore version on restore' do
      account = create :account, :soft_deleted
      with_versioning do
        expect do
          account.restore
        end.to change(PaperTrail::Version, :count).by(1)
      end
      expect(account.versions.last.event).to eq('restore')
    end
  end

  describe '.find_for_oauth' do
    it 'raises an illegal argument error with an invalid provider' do
      expect do
        auth_hash_double = double('auth_hash', provider: 'does-not-exist', uid: '1234')
        Account.find_for_oauth auth_hash_double, 'does-not-exist'
      end.to raise_error(ArgumentError)
    end
    it 'raises an exception if the provider does not match the expected value' do
      expected_message = "Provider (twitter) doesn't match expected value: not_matching_provider"
      expect do
        Account.find_for_oauth(twitter_auth_hash, 'not_matching_provider')
      end.to raise_error(Exception, expected_message)
    end
  end

  describe '.new_with_auth_hash' do
    it 'raises an exception if the provider does not match the expected value' do
      expected_message = "Provider (twitter) doesn't match expected value: not_matching_provider"
      expect do
        Account.new_with_auth_hash(twitter_auth_hash, 'not_matching_provider')
      end.to raise_error(Exception, expected_message)
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
    it { expect { subject.account_uid }.to raise_error(NotImplementedError) }
  end

  describe '#provider' do
    it { expect { subject.provider }.to raise_error(NotImplementedError) }
  end

  describe '#provider_name' do
    it { expect { subject.provider_name }.to raise_error(NotImplementedError) }
  end

  describe '#profile_picture' do
    it 'returns the image' do
      fake_image = Object.new
      expect(subject).to receive(:image).and_return(fake_image)
      expect(subject.profile_picture).to be(fake_image)
    end
  end

  describe '#remove_oauth_credentials' do
    context 'with an account with oauth credentials' do
      subject do
        build_stubbed(:developer_account,
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
      it 'should set the website to nil' do
        subject.send(:update_from_auth_hash, auth_hash)
        expect(subject.website).to be_nil
      end
    end
  end
end
