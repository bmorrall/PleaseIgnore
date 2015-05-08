require 'rails_helper'

describe AuthenticationTokens::PurgeOldTokensJob do
  it 'should belong to the low_priority queue' do
    expect(described_class.queue_name).to eq 'low_priority'
  end

  describe '.perform' do
    subject { described_class.perform_now }

    it 'should call Tiddle.purge_old_tokens on users with excessive tokens' do
      user = create(:user)
      (Tiddle::TokenIssuer::MAXIMUM_TOKENS_PER_USER + 1).times do
        create :authentication_token, user: user
      end

      expect(Tiddle).to receive(:purge_old_tokens).with(user).once
      subject
    end
    it 'should ignore users with insufficient tokens' do
      user = create(:user)

      expect(Tiddle).to_not receive(:purge_old_tokens).with(user)
      subject
    end
  end
end
