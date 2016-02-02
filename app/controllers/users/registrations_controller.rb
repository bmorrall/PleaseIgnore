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

    before_filter :ensure_destroy_permission!, only: :destroy

    helper_method :display_accounts?
    helper_method :display_profile?
    helper_method :display_password_change?

    # Attempts to save the Password or the Profile for the `current_user`.
    #
    # Keeps the User signed in upon a successful update.
    #
    # Renders the edit form for any errors.
    # @api public
    # @example PUT /users
    # @return void
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

    # Filters

    # Checks that the user can destroy their own account
    #
    # @raise [CanCan::AccessDenied] if the current user cannot be destroyed
    # @api private
    # @return void
    def ensure_destroy_permission!
      authorize! :destroy, current_user
    end

    # Helpers

    # Params for updating a user profile
    # @api private
    # @return [Hash] Santitized Params for updating a User
    def account_update_params
      devise_parameter_sanitizer.sanitize(:account_update)
    end

    # Returns layout backend layout except for profile page
    # @api private
    # @return [String] Layout for rendering the current action
    def registrations_layout
      %w(edit update).include?(params[:action]) ? 'dashboard_backend' : 'backend'
    end

    # Updates Account or Changes Password depending on params
    # @api private
    # @return [Boolean] success if the current_user is updated
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

    concerning :DeviseOverrides do
      protected

      # [Devise] Redirect Users back to the profile page after updates
      #
      # @param _resource [User] resource requiring redirect
      # @return [String] path to redirect the user to after a successful update
      def after_update_path_for(_resource)
        edit_user_registration_path
      end

      # [Devise] Returns true if new password param is included
      # @return [Boolean] true if the passwords param is required
      def needs_password_param?(_user, params)
        params.key? :password
      end
    end

    concerning :Helpers do
      # Only display password on #show or if update profile fails
      def display_profile?
        params[:user].nil? || !params[:user].key?(:password)
      end

      # Only display password on #show or if change password fails
      def display_password_change?
        !params[:user].nil? && params[:user].key?(:password)
      end

      # Only display accounts on #show
      def display_accounts?
        params[:user].nil?
      end
    end
  end
end
