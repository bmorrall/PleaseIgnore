module Workers
  # Ensures an ActiveJob uses a threadsafe connection pool and logs all exceptions
  module BackgroundJob
    def self.included(base)
      # Ensure all perform commands destroy the db connection on finish (Sucker Punch / Async)
      base.send :around_perform do |_job, block|
        ActiveRecord::Base.connection_pool.with_connection do
          block.call
        end
      end

      # Log all exceptions using the logging railtie
      base.send :rescue_from, Exception do |exception|
        Logging.log_error(exception, job: self.class.name, job_id: job_id)
        raise exception
      end
    end
  end
end
