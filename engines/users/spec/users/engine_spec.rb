require 'spec_helper'

describe Users::Engine do
  it 'should setup Devise::Async to use ActiveJob' do
    expect(Devise::Async.backend).to eq :active_job
    expect(Devise::Async.enabled).to eq true
    expect(Devise::Async.queue).to eq Workers::MAILERS
  end

  it 'should add Workers::BackgroundJob to the Devise::Async Runner' do
    expect(Devise::Async::Backend::ActiveJob::Runner.new).to be_kind_of(Workers::BackgroundJob)
  end
end
