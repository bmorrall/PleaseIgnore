# Allows for hourly and daily scheduled tasks to be run (and tested)
class Cron
  # Enqueues all daily cron tasks
  #
  # Should only enqueue tasks for ActiveJob to perform, as this task should be lightweight
  #
  # @api public
  # @example Run all daily cron tasks
  #   "Cron.daily"
  # @return void
  def self.daily
    Rollbar.debug('Daily cron task')

    AuthenticationTokens::PurgeOldTokensJob.perform_later
    Users::ArchiveExpiredUsersJob.perform_later

    # Add Daily Cron Tasks after this line
  end

  # Enqueues all hourly cron tasks
  #
  # Should only enqueue tasks for ActiveJob to perform, as this task should be lightweight
  #
  # Use Time.now.hour to control hour task is run (i.e. `Time.now.hour % 4 == 0` for every 4 hours)
  #
  # The current time zone is UTC, so user time zones must be taken into account.
  #
  # @api public
  # @example Run all hourly cron tasks for the current hour
  #   "Cron.hourly"
  # @return void
  def self.hourly
    Rollbar.debug('Hourly cron task')

    # Add Hourly Cron Tasks after this line
  end
end
