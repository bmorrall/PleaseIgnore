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
  it_behaves_like 'a soft deletable model'

  describe 'Associations' do
    it { is_expected.to belong_to(:user).touch }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:uid) }
    it 'should validate uniqueness of uid scoped to provider' do
      create(:developer_account)
      is_expected.to validate_uniqueness_of(:uid).scoped_to(:type)
    end

    it { is_expected.to validate_presence_of(:user_id) }
    it 'should validate uniqueness of user_id scoped to provider' do
      create(:developer_account)
      is_expected.to validate_uniqueness_of(:user_id).scoped_to(:type)
    end

    context 'with a existing soft deleted account' do
      let!(:account) { create(:developer_account, :soft_deleted) }
      # Ensure validate_uniqueness_of compares against soft deleted model
      before(:each) { expect(described_class).to receive(:first).and_return(account) }

      it { is_expected.not_to validate_uniqueness_of(:uid).scoped_to(:type) }
      it { is_expected.not_to validate_uniqueness_of(:user_id).scoped_to(:type) }
    end
  end

  describe 'Versioning', :paper_trail do
    context 'with create event' do
      it 'creates a create version' do
        account = build :account
        with_versioning do
          expect do
            account.save!
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(account.versions.last.event).to eq('create')
      end
      it 'should assign the item_owner to the user' do
        user = create(:user)
        account = build :account, user: user
        with_versioning do
          account.save!
        end
        expect(account.versions.first.item_owner).to eq(user)
      end
    end

    context 'with destroy event' do
      it 'creates a destroy version' do
        account = create :account
        with_versioning do
          expect do
            account.destroy
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(account.versions.last.event).to eq('destroy')
      end
    end

    context 'with restore event' do
      it 'creates a restore version' do
        account = create :account, :soft_deleted
        with_versioning do
          expect do
            account.restore
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(account.versions.last.event).to eq('restore')
      end
      it 'should touch the user model' do
        account = create :account, :soft_deleted
        user = account.user
        with_versioning do
          expect do
            account.restore
            user.reload
          end.to change(user, :updated_at)
        end
      end
    end

    context 'with update event' do
      it 'creates a update version when user_id is changed' do
        account = create :account
        with_versioning do
          expect do
            account.update_attribute :user_id, account.user_id + 1
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(account.versions.last.event).to eq('update')
      end
      it 'creates a update version when type is changed' do
        account = create :account
        with_versioning do
          expect do
            account.update_attribute :type, Accounts::Facebook.class.name
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(account.versions.last.event).to eq('update')
      end
      it 'ignores omniauth assigned properties' do
        account = create :account
        with_versioning do
          expect do
            account.update_attributes(
              name: Faker::Name.name,
              nickname: Faker::Name.first_name,
              image: Faker::Avatar.image,
              website: Faker::Internet.url,
              oauth_token: Faker::Code.rut,
              oauth_secret: Faker::Code.isbn,
              oauth_expires_at: DateTime.now
            )
          end.to_not change(PaperTrail::Version, :count)
        end
      end
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
      auth_hash = create(:twitter_auth_hash)
      expected_message = "Provider (twitter) doesn't match expected value: not_matching_provider"
      expect do
        Account.find_for_oauth(auth_hash, 'not_matching_provider')
      end.to raise_error(Exception, expected_message)
    end
  end

  describe '.new_with_auth_hash' do
    it 'raises an exception if the provider does not match the expected value' do
      expected_message = "Provider (twitter) doesn't match expected value: not_matching_provider"
      auth_hash = create(:twitter_auth_hash)
      expect do
        Account.new_with_auth_hash(auth_hash, 'not_matching_provider')
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
