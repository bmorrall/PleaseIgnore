require 'spec_helper'

describe Workers::Railtie do
  it 'should have set ActiveJob::Base.queue_adapter to sidekiq' do
    expect(ActiveJob::Base.queue_adapter).to be(ActiveJob::QueueAdapters::SidekiqAdapter)
  end

  it 'should add Workers::BackgroundJob to ActionMailer::DeliveryJob' do
    expect(ActionMailer::DeliveryJob.new).to be_kind_of(Workers::BackgroundJob)
  end
end
