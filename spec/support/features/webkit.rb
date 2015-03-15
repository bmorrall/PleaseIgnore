# Use webkit for js features
Capybara.javascript_driver = :webkit

# Allow known CDN urls to connect to the outside world
RSpec.configure do |config|
  config.before(js: true) do
    Capybara.current_session.driver.tap do |driver|
      driver.block_unknown_urls
      driver.allow_url('ajax.googleapis.com') # Allow CDN Hosted jQuery
      driver.allow_url('fonts.googleapis.com') # Allow Custom Fonts
    end if Capybara.current_session.driver.respond_to? :block_unknown_urls
  end
end
