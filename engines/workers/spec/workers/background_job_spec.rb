require 'spec_helper'

describe Workers::BackgroundJob do
  # An Example Exception class for testing error handling
  class BackgroundJobExampleError < StandardError; end

  # Raises a ExampleError when the job is performed
  class FailingBackgroundJobExample < ActiveJob::Base
    include Workers::BackgroundJob
    def perform
      raise BackgroundJobExampleError, 'This is an example error'
    end
  end

  it 'should wrap #perform in a ActiveRecord::Base.connection block' do
    # Assert that perform was not called (due to a stubbed out block)
    expect_any_instance_of(FailingBackgroundJobExample).to_not receive(:perform)

    # Prevent ActiveRecord::Base.connection_pool.with_connection from calling perform
    expect(ActiveRecord::Base.connection_pool).to receive(:with_connection)

    # Run the example, expecting #peform to not be called due to stubbing
    expect { FailingBackgroundJobExample.perform_now }.to_not raise_error
  end

  it 'should log and re-raise exceptions' do
    expect(Logging).to receive(:log_error).with(
      kind_of(BackgroundJobExampleError),
      job: 'FailingBackgroundJobExample',
      job_id: kind_of(String)
    )

    expect do
      FailingBackgroundJobExample.perform_now
    end.to raise_error(BackgroundJobExampleError, 'This is an example error')
  end
end
