module Rack
  # Rack::Attack is used to prevent brute force attacks and the like
  # see. https://github.com/kickstarter/rack-attack
  class Attack
    SIGN_IN_URLS = %w(/users/sign_in /api/v1/session).freeze

    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blacklisting and
    # whitelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip if req.path.starts_with?('/api/v1')
    end

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.

    # Throttle POST requests to /login by IP address
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if SIGN_IN_URLS.include?(req.path) && req.post?
    end

    # Throttle POST requests to /login by email param
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
    #
    # Note: This creates a problem where a malicious user could intentionally
    # throttle logins for another user and force their login requests to be
    # denied, but that's not very common and shouldn't happen to you. (Knock
    # on wood!)
    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      req.params['user'].try(:[], 'email').presence if SIGN_IN_URLS.include?(req.path) && req.post?
    end
  end
end
