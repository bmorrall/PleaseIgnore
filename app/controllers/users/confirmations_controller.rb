# Classes for Managing the Current User Session
module Users
  # Users Confirmations Controller
  # Allows Users to confirm their account
  class ConfirmationsController < Devise::ConfirmationsController
    before_action except: [:show] { authenticate_user! force: true }

    layout 'backend'

    protected

    # [Devise] The path used after resending confirmation instructions.
    # @api private
    # @return [String] A redirect to the users dashboard
    def after_resending_confirmation_instructions_path_for(_resource_name)
      dashboard_path
    end

    # [Devise] The path used after the user has confirmed their account
    # @api private
    # @return [String] A redirect to the Users dashboard or the login forms
    def after_confirmation_path_for(_resource_name, _resource)
      if user_signed_in?
        dashboard_path
      else
        new_user_session_path
      end
    end

    # [Devise] Confirmation only works when the user is signed in
    # @api private
    # @return [Hash] The Users email address if they are signed in
    def resource_params
      user_signed_in? ? { email: current_user.email } : {}
    end
  end
end
