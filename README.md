[![Build
Status](https://travis-ci.org/bmorrall/PleaseIgnore.png?branch=master)](https://travis-ci.org/bmorrall/PleaseIgnore)
[![Coverage
Status](https://coveralls.io/repos/bmorrall/PleaseIgnore/badge.png)](https://coveralls.io/r/bmorrall/PleaseIgnore)
[![Code Climate](https://codeclimate.com/github/bmorrall/PleaseIgnore.png)](https://codeclimate.com/github/bmorrall/PleaseIgnore)
[![Dependency Status](https://gemnasium.com/bmorrall/PleaseIgnore.png)](https://gemnasium.com/bmorrall/PleaseIgnore)

PleaseIgnore README
===================

Rails version
-------------

PleaseIgnore currently runs on `Rails 4.2.3`.

Ruby version
------------

In order to main compatability with Heroku, PleaseIgnore is designed to run on `MRI Ruby 2.2.0`. This project will be continually updated to matchin newer versions of Ruby and Rails.

PleaseIgnore should not make any assumptions, nor have any dependencies on how Ruby is installed on its host system, however the development environment has been configured to use [rbenv](https://github.com/sstephenson/rbenv).

Dependencies
============

JavaScript runtime
------------------

JavaScript asset compilation in Rails 4 requires a JavaScript runtime to be installed on the host system.

[Node.js](http://nodejs.org/) is currently the most popular one available, and comes with various tools that PleaseIgnore makes use of.

Front-end package management
----------------------------

Front-end libraries are managed using [Bower](http://bower.io/). Bower downloads libraries; configured in `bower.json`, and saves them to `vendor/assets/components`.

Assuming you have installed `Node.js`, run the following to install Bower and download all required frontend assets.

    npm install
    node_modules/.bin/bower install

Configuration
=============

Email Configuration
-------------------

Set the following env vars in order to use email addresses.

Address                  | Purpose                                                                 |
-------------------------|-------------------------------------------------------------------------|
`ACCOUNTS_EMAIL_ADDRESS` | Email for handling user accounts (registration, password reset, etc...) |
`SUPPORT_EMAIL_ADDRESS`  | Email for receiving any support issues (contact request, etc...)        |
`CONTACT_EMAIL_ADDRESS`  | Email sent from the Contact Request form.                               |

SendGrid Configuration
----------------------
<img src="http://assets3.sendgrid.com/mkt/assets/logos_brands/small/logo_full_color_flat-198f020c78782e28250e0ec40fcee652.jpg">

- Sign up for [SendGrid](http://sendgrid.com/) or add it as [a plugin to your heroku app](https://devcenter.heroku.com/articles/sendgrid).
- Copy and paste *Username* and *Password* keys into `SENDGRID_USERNAME` and `SENDGRID_PASSWORD` environment variables.

Google Analytics Configuration
------------------------------

- Sign up for [Google Analytics](http://www.google.com/analytics/) and generate a Analytics ID
- Copy and paste the *Analytics ID* into the `GOOGLE_ANALYTICS_ID` environment variable.

OAuth Configuration
-------------------

If you want to use any of the OAuth authentication methods, you will need to obtain
appropriate credentials: Client ID, Client Secret, API Key, or Username & Password. You will
need to go through each provider to generate new credentials.

:pushpin: You could support all 5 authentication methods by setting up OAuth keys, but you don't have to. If you would only like to have **Facebook sign-in** and **Local sign-in** with email and password; in **config/initializers/devise.rb** remove the lines: `config.omniauth :facebook` for the providers you no longer wish to keep. By doing so, *Google, Twitter and Github* buttons will not show up on the *Login* or *Edit Profile* page.

<img src="http://www.doit.ba/img/facebook.jpg" width="200">

- Visit [Facebook Developers](https://developers.facebook.com/)
- Click **Apps > Create a New App** in the navigation bar
- Enter *Display Name*, then choose a category, then click **Create app**
- Copy and paste *App ID* and *App Secret* keys into `FACEBOOK_APP_ID` and `FACEBOOK_APP_SECRET` environment variables.
- Click on *Settings* on the sidebar, then click **+ Add Platform**
- Select **Website**
- Enter `http://pleaseignore.com` for *Site URL*

:exclamation: **Note**: After a successful sign in with Facebook, a user will be redirected back to home page with appended hash `#_=_` in the URL. It is *not* a bug. See this [Stack Overflow](https://stackoverflow.com/questions/7131909/facebook-callback-appends-to-return-url) discussion for ways to handle it.

<hr>

<img src="https://g.twimg.com/Twitter_logo_blue.png" width="100">

- Sign in at [https://dev.twitter.com](https://dev.twitter.com/)
- From the profile picture dropdown menu select **My Applications**
- Click **Create a new application**
- Enter your application name, website and description
- For **Callback URL**: http://pleaseignore.com/auth/twitter/callback
- Go to **Settings** tab
- Under *Application Type* select **Read and Write** access
- Check the box **Allow this application to be used to Sign in with Twitter**
- Click **Update this Twitter's applications settings**
- Copy and paste *Consumer Key* and *Consumer Secret* keys into `TWITTER_CONSUMER_KEY` and `TWITTER_CONSUMER_SECRET` environment variables.

<hr>

<img src="https://github.global.ssl.fastly.net/images/modules/logos_page/GitHub-Logo.png" width="200">

- Go to [Account Settings](https://github.com/settings/profile)
- Select **Applications** from the sidebar
- Then inside **Developer applications** click on **Register new application**
- Enter *Application Name* and *Homepage URL*.
- For *Authorization Callback URL*: http://pleaseignore.com/auth/github/callback
- Click **Register application**
- Now copy and paste *Client ID* and *Client Secret* keys into `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` environment variables.

<hr>

<img src="http://images.google.com/intl/en_ALL/images/srpr/logo6w.png" width="200">

- Visit [Google Cloud Console](https://cloud.google.com/console/project)
- Click **CREATE PROJECT** button
- Enter *Project Name*, then click **CREATE**
- Then select *APIs & auth* from the sidebar and click on *Credentials* tab
- Click **CREATE NEW CLIENT ID** button
 - **Application Type**: Web Application
 - **Authorized Javascript origins**: http://pleaseignore.com
 - **Authorized redirect URI**: http://pleaseignore.com/auth/google_oauth2/callback
- Copy and paste *Client ID* and *Client secret* keys into `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables.

:exclamation: **Note**: When you ready to deploy to production don't forget to add your new url to *Authorized Javascript origins* and *Authorized redirect URI*, e.g. `http://pleaseignore.com` and `http://pleaseignore.com/auth/google_oauth2/callback` respectively. The same goes for other providers.

Development setup
=================

Database creation
-----------------

Running `rake db:reset` will build the database, based on the stored `db/schema.rb`.

Rails 4.1 automatically migrates and clears the test database whenever the test suite is run.

Database initialization
-----------------------

Currently, nothing needs to be setup in order to start using PleaseIgnore.

Sign up a new account using the registration form with your name, email address and password.

You may wish to promote your account to an admin account by running the following command in the rails console `bin/rails c`

    User.find_by(email: '<your email address>').add_role(:admin)

How to run the test suite
-------------------------

Unit tests are provided with [RSpec](http://rspec.info/). Integration tests are provided with [Cucumber](http://cukes.info/), running [capybara-webkit](https://github.com/thoughtbot/capybara-webkit).

Both can be run by running `bundle exec rake travis`, or can be individually run with `bin/rspec` and `bin/cucumber` respectively.

Services
========

(job queues, cache servers, search engines, etc.)
-------------------------------------------------

Deployment instructions
=======================

Vagrant Staging
---------------

Install [Vagrant](https://www.vagrantup.com/) and run `/bin/vagrant` to provision a local staging server.

The server can be accessed from http://localhost:8080/.

Deployment on Heroku
--------------------

Starting Sidekiq
----------------

[Sidekiq](https://github.com/mperham/sidekiq) is used to perform background jobs (mailers, cron tasks, etc). A basic config file that covers all known job types can be found at `config/sidekiq.yml`.

A Sidekiq worker can be started by running: `sidekiq -C config/sidekiq.yml`.

Whenever
--------

[Whenever](https://github.com/javan/whenever) is used to setup daily and hourly cron tasks. Use `whenever --update-crontab` to convert `config/schedule.rb` into a crontab.

### Initial setup

Heroku requires a custom buildpack in order to install `Bower` components via NodeJS.

`heroku config:set BUILDPACK_URL='git://github.com/qnyp/heroku-buildpack-ruby-bower.git#run-bower'`

More details can be found at: https://gist.github.com/afeld/5704079.

### Required addons

Initial installation requires the Postgres addon to be added to the dyno.

`heroku addons:add heroku-postgresql`

## Updating Libraries

### Ruby/Rails

Run `bundle update` to update all unlocked gems to the latest version.
Verify everything works by running `rake travis`.
Then individually unlock gems and run `bundle update` until updated to a satisfactory level.
