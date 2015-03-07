# Classes for Managing the Current User Session
module Users
  # Users Registrations Controller
  # Allows Guests to register a new User account
  #
  # Overrides Devise::RegistrationsController to allow for:
  # - Showing/Hiding elements of edit user page
  # - Allows user to edit their details without providing a password
  # - Provides separate profile update and password change forms
  class RegistrationsController < Devise::RegistrationsController
    layout :registrations_layout

    helper_method :display_accounts?
    helper_method :display_profile?
    helper_method :display_password_change?

    # PUT /users
    #
    # Attempts to save the Password or the Profile for the `current_user`.
    #
    # Keeps the User signed in upon a successful update.
    #
    # Renders the edit form for any errors.
    def update
      @user = User.find(current_user.id)

      # Update profile or password
      if save_account_or_password
        set_flash_message :notice, @success_message
        sign_in @user, bypass: true
        redirect_to after_update_path_for(@user)
      else
        render :edit
      end
    end

    protected

    # [Rails] Params for updating a user profile
    def account_update_params
      devise_parameter_sanitizer.sanitize(:account_update)
    end

    # [Devise] Redirect Users back to the profile page after updates
    #
    # @param _resource [User] resource requiring redirect
    def after_update_path_for(_resource)
      edit_user_registration_path
    end

    # Only display password on #show or if update profile fails
    def display_profile?
      params[:user].nil? || !params[:user].key?(:password)
    end

    # Only display password on #show or if change password fails
    def display_password_change?
      params[:user].nil? || params[:user].key?(:password)
    end

    # Only display accounts on #show
    def display_accounts?
      params[:user].nil?
    end

    # Returns layout backend layout except for profile page
    def registrations_layout
      %w(edit update).include?(params[:action]) ? 'dashboard_backend' : 'backend'
    end

    # Updates Account or Changes Password depending on params
    def save_account_or_password
      if needs_password_param?(@user, account_update_params)
        @success_message = :updated_password
        @user.update_with_password account_update_params
      else
        @success_message = :updated
        account_update_params.delete(:current_password)
        @user.update_without_password account_update_params
      end
    end

    private

    # [Devise] Returns true if new password param is included
    def needs_password_param?(_user, params)
      params.key? :password
    end
  end
end
