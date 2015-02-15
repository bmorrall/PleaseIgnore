#!/bin/sh
# run Sidekiq as the app user
cd /home/app/webapp
su app -c "RAILS_ENV=production bundle exec sidekiq" >> /var/log/sidekiq.log 2>&1
