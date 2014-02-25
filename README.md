[![Build
Status](https://travis-ci.org/bmorrall/PleaseIgnore.png?branch=master)](https://travis-ci.org/bmorrall/PleaseIgnore)
[![Coverage
Status](https://coveralls.io/repos/bmorrall/PleaseIgnore/badge.png)](https://coveralls.io/r/bmorrall/PleaseIgnore)

PleaseIgnore README
===================

Ruby version
------------

System dependencies
-------------------

SendGrid Configuration
----------------------
<img src="http://assets3.sendgrid.com/mkt/assets/logos_brands/small/logo_full_color_flat-198f020c78782e28250e0ec40fcee652.jpg">

- Sign up for [SendGrid](http://sendgrid.com/) or add it as [a plugin to your heroku app](https://devcenter.heroku.com/articles/sendgrid).
- Copy and paste *Username* and *Password* keys into `SENDGRID_USERNAME` and `SENDGRID_PASSWORD` environment variables.

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


Database creation
-----------------

Database initialization
-----------------------

How to run the test suite
-------------------------

Services (job queues, cache servers, search engines, etc.)
----------------------------------------------------------

Deployment instructions
-----------------------
