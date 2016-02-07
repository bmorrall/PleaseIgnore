require 'rails_helper'

describe Cron do
  include ActiveSupport::Testing::TimeHelpers

  before do
    allow(AuthenticationTokens::PurgeOldTokensJob).to receive(:perform_later)
  end

  after do
    travel_back
  end

  describe '.daily' do
    subject { described_class.daily }

    it 'runs daily jobs' do
      expect(AuthenticationTokens::PurgeOldTokensJob).to receive(:perform_later).with(no_args)
      expect(Users::ArchiveExpiredUsersJob).to receive(:perform_later).with(no_args)

      travel_to(Time.now.midnight) do
        subject
      end
    end
  end

  describe '.hourly' do
    subject { described_class.hourly }

    it 'runs hourly jobs' do
      now = Time.now.midnight + 1.hour

      expect(AuthenticationTokens::PurgeOldTokensJob).to_not receive(:perform_later)

      travel_to(now) do
        subject
      end
    end
  end
end
