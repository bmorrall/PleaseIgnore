# Classes for Managing the Current User Session
module Users
  # Users Sessions Controler
  # Allows Guests to sign in and sign out as a User
  class SessionsController < Devise::SessionsController
    # DELETE /users/sign_out
    def destroy
      super
      flash.delete(:notice) # Remove flash message
    end
  end
end
