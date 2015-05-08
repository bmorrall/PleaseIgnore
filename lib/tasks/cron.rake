namespace :cron do
  desc 'Run daily Cron tasks'
  task daily: :environment do
    Cron.daily
  end

  desc 'Run hourly Cron tasks'
  task hourly: :environment do
    Cron.hourly
  end
end
