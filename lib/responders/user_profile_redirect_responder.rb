# Custom Rails Responders
module Responders
  # This responder modifies your current responder to redirect
  # to a Users profile page (edit_user_registration_path) upon receiving a
  # successful POST/PUT/DELETE response.
  #
  # === Examples
  #
  #   user = User.first
  #
  #   respond_with user
  #   # => redirect to /users/edit
  #
  #  respond_with user, location: root_url
  #   # => redirect to /
  #
  module UserProfileRedirectResponder
    protected

    # Changes redirect url to /user/edit used by successful POST/PUT/DELETE response.
    # Can be overridden by the :location option flag.
    def navigation_location
      return options[:location] if options[:location]
      [:edit, :user, :registration]
    end
  end
end
