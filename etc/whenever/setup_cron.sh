#!/bin/sh
# Converts whenever schedule into cron task
cd /home/app/webapp
su app -c "RAILS_ENV=production whenever --update-crontab"
