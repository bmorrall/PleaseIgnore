require 'workers'

# Run Sidekiq jobs inline
require 'sidekiq/testing'
Sidekiq::Testing.inline! # Run specs inline
Sidekiq.logger = nil # Silence logging messages

VALID_WORKER_QUEUES = [
  Workers::HIGH_PRIORITY,
  Workers::DEFAULT,
  Workers::LOW_PRIORITY,
  Workers::MAILERS
].map(&:to_s).freeze

# Returns all workers of type klass
def enqueued_workers_with_class(klass, queue)
  ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.jobs.select do |job|
    job_klass = job['wrapped']
    job_queue = job['queue']
    unless VALID_WORKER_QUEUES.include?(job_queue)
      raise "#{job_klass} has invalid queue: #{job_queue}"
    end
    (klass.nil? || job_klass == klass.name) && (queue.nil? || job_queue == queue.to_s)
  end
end

# Returns all jobs used to deliver a mailer
def enqueued_mailers_with_method(mailer_klass, mailer_method, queue)
  enqueued_workers_with_class(ActionMailer::DeliveryJob, queue).select do |job|
    # ['ExampleMailer', 'email_method', params...]
    delivery_arguments = job['args'][0]['arguments']
    delivery_arguments[0] == mailer_klass.name && delivery_arguments[1] == mailer_method.to_s
  end
end

# Matches for asserting that a mailer has been enqueued
RSpec::Matchers.define :enqueue_a_mailer do |mailer_klass, mailer_method, queue: nil, count: 1|
  raise 'Your spec is missing a "queue_workers" tag!' unless Sidekiq::Testing.fake?

  match do |actual|
    # Ensure the expected number of jobs are enqueued
    expect do
      actual.call
    end.to change {
      enqueued_mailers_with_method(mailer_klass, mailer_method, queue).size
    }.by(count)
  end

  def supports_block_expectations?
    true
  end

  diffable
end

# Matcher for asserting that a job has been enqueued
RSpec::Matchers.define :enqueue_a_worker do |worker_klass = nil, queue: nil, count: 1|
  raise 'Your spec is missing a "queue_workers" tag!' unless Sidekiq::Testing.fake?

  match do |actual|
    expect do
      actual.call
    end.to change { enqueued_workers_with_class(worker_klass, queue).size }.by(count)
  end

  def supports_block_expectations?
    true
  end

  diffable
end

# Matcher for asserting that a mailer has been delivered
RSpec.configure do |c|
  # Add inline_jobs tag to run workers inline
  c.around(:each, :inline_workers) do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  # Add queued_workers to add Workers into a 'fake' background queue
  c.around(:each, :queue_workers) do |example|
    Sidekiq::Worker.clear_all
    Sidekiq::Testing.fake! do
      example.run
    end
  end
end
