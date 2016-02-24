require 'rails_helper'

describe Cron do
  include ActiveSupport::Testing::TimeHelpers

  after do
    travel_back
  end

  describe '.daily', :queue_workers do
    around do |example|
      travel_to(Time.now.midnight) { example.run }
    end

    it 'enqueues a AuthenticationTokens::PurgeOldTokensJob' do
      expect { described_class.daily }.to enqueue_a_worker(AuthenticationTokens::PurgeOldTokensJob)
    end
    it 'enqueues a Users::ArchiveExpiredUsersJob' do
      expect { described_class.daily }.to enqueue_a_worker(Users::ArchiveExpiredUsersJob)
    end
  end

  describe '.hourly', :queue_workers do
    it 'runs hourly jobs' do
      midnight = Time.now.midnight

      23.times do |offset|
        travel_to(midnight + offset.hours) do
          expect { described_class.hourly }.to_not enqueue_a_worker
        end
      end
    end
  end
end
