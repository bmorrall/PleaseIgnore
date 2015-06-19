source 'https://rubygems.org'

ruby '2.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-rails-cdn'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 2.5.3'
gem 'turboboost', git: 'https://github.com/waymondo/turboboost.git'

# Use Twitter Bootstrap for base stylesheet
gem 'bootstrap-sass'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder' # , '~> 1.2'

# Use simple form to simplify forms
gem 'simple_form', '~> 3.1.0'

gem 'acts_as_list'

# User authentication with Devise
gem 'devise', '~> 3.5.1'

# Use Action Caching to save pages
gem 'actionpack-action_caching'

# Omniauth providers
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'

# Use Haml for cleaner HTML
gem 'haml'

# Static Pages served with high_voltage
gem 'high_voltage'

# Use flutie for page_title and body_class
gem 'flutie'

# Soft Delete Critical Records
gem 'paranoia', '~> 2.0'

# Use redcarpet for markdown parseing
gem 'redcarpet'

# Use sendgrid to send emails
gem 'sendgrid'

# Fix assets for Bower
gem 'non-stupid-digest-assets'

# Use Draper for Decorators
gem 'draper'

# Use Responders for Dry-ing up responses
gem 'responders'

# Use CanCanCan for Authorization
gem 'cancancan'

# Use local time to parse time
gem 'local_time'

# Use Rolify to Mnnage User Roles
gem 'rolify'

# Use Sidekiq for background jobs
gem 'sinatra', require: false # required by Sidekiq::Web
gem 'sidekiq', '~> 3.4.0'

# Send Devise mail through Sidekiq
gem 'devise-async'
gem 'devise-async-activejob'

# Leave a Paper Trail
gem 'paper_trail'

# Add Application Name Prefix to Emails
gem 'email_prefixer'

# Adds ActiveModel::Errors#details display method
gem 'active_model-errors_details'

# Authentication
# ==============

gem 'tiddle'

# Dashboard
# ==============

gem 'cells', '~> 3.11.3'
gem 'cells-dashboard'

# Helpers
# ==============

# Allows for User Agent string to be interrogated
gem 'useragent'

# Cron
# ==============

gem 'whenever', require: false

# Security
# ==============

gem 'rack-attack'

# Devops
# ==============

gem 'rollbar', '~> 1.5.1'

group :production do
  # Integration with heroku
  gem 'rails_12factor'

  # Use Passenger as the app server
  gem 'passenger', '~> 5.0.9'

  # Use Memcached as a cache
  gem 'dalli', '~> 2.7.4'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'annotate' # Annotate models with db schema
  gem 'quiet_assets'
  gem 'rack-mini-profiler' # Add a profiling tab to each page

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :test, :development do
  gem 'rspec-rails', '~> 3.3.2'
  gem 'pry-rails'

  # Code Quality Metrics
  gem 'i18n-tasks', require: false
  gem 'brakeman', require: false
  gem 'cane', require: false
  gem 'rubocop', require: false
  gem 'yardstick', require: false
end
group :test do
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'email_spec'
  gem 'rspec-its'
  gem 'shoulda-matchers', require: false
end
