module Responders
  # This responder modifies your current responder to redirect
  # to edit_user_registration_path on POST/PUT/DELETE.
  module UserProfileResourceResponder
    protected

    def navigation_location
      return options[:location] if options[:location]
      [:edit, :user, :registration]
    end
  end
end
