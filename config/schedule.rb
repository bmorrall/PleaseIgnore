# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :output, error: 'log/cron_errors.log', standard: 'log/cron.log'

every :day do
  rake 'cron:daily'
end

every :hour do
  rake 'cron:hourly'
end

# Learn more: http://github.com/javan/whenever
