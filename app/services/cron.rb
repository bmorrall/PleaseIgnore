# Allows for hourly and daily scheduled tasks to be run (and tested)
class Cron
  # Runs all daily cron tasks
  def self.daily
    Rollbar.debug('Daily cron task')

    AuthenticationTokens::PurgeOldTokensJob.perform_later

    # Add Daily Cron Tasks after this line
  end

  # Runs all hourly cron tasks
  # Use Time.now.hour to control hour task is run (i.e. `Time.now.hour % 4 == 0` for every 4 hours)
  def self.hourly
    Rollbar.debug('Hourly cron task')

    # Add Hourly Cron Tasks after this line
  end
end
