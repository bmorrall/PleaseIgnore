require 'spec_helper'

describe Workers do
  it 'should have a version' do
    expect(Workers::VERSION).to_not be_nil
  end

  describe '.sidekiq_config' do
    it 'should return configurable parameters for Sidekiq' do
      sidekiq_namespace = Faker::Lorem.word
      redis_url = "redis://#{Faker::Internet.domain_word}:6379/tcp/0"

      allow(Workers.configuration).to receive(:sidekiq_namespace).and_return(sidekiq_namespace)
      allow(Workers.configuration).to receive(:redis_url).and_return(redis_url)

      expect(Workers.sidekiq_config).to eq(
        namespace: sidekiq_namespace,
        network_timeout: 2,
        url: redis_url
      )
    end
  end
end
