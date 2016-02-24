require 'rails_helper'

describe Users::ArchiveExpiredUsersJob do
  describe '#perform' do
    subject { described_class.new.perform }

    it 'should call the Users::ArchiveExpiredUser with an expired user with an email' do
      expired_user = create(:user, :expired, email: Faker::Internet.email)
      expect(Users::ArchiveExpiredUser).to receive(:call).with(expired_user)
      subject
    end

    it 'should call the Users::ArchiveExpiredUser with an expired user with an account' do
      expired_user = create(:user, :expired, :with_auth_hash, email: nil)
      expect(Users::ArchiveExpiredUser).to receive(:call).with(expired_user)
      subject
    end

    it 'should return the number of successful jobs' do
      expired_user_a = create(:user, :expired)
      expired_user_b = create(:user, :expired, :with_auth_hash, email: nil)
      expired_user_c = create(:user, :expired, email: nil)
      deleted_user = create(:user, :soft_deleted)
      regular_user = create(:user)

      expect(Users::ArchiveExpiredUser).to receive(:call).with(expired_user_a)
      expect(Users::ArchiveExpiredUser).to receive(:call).with(expired_user_b)
      expect(Users::ArchiveExpiredUser).to_not receive(:call).with(expired_user_c)
      expect(Users::ArchiveExpiredUser).to_not receive(:call).with(deleted_user)
      expect(Users::ArchiveExpiredUser).to_not receive(:call).with(regular_user)
      expect(subject).to eq 2
    end

    it 'should notify Rollbar for any failed jobs' do
      invalid_user = create(:user, :expired)
      invalid_user.errors.add(:base, 'test forced update to fail')
      error = ActiveRecord::RecordInvalid.new(invalid_user)

      expect(Users::ArchiveExpiredUser).to receive(:call).with(invalid_user).and_raise(error)
      expect(Logging).to receive(:log_error).with(
        error, user_id: invalid_user.id, errors: kind_of(Hash)
      )
      expect(subject).to eq 0
    end
  end
end
