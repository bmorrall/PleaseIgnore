module Api
  module V1
    # Allows Guests to Register a new account via the API
    class RegistrationsController < Api::V1::ApplicationController
      before_action :add_registration_params

      # Registeres a new account from a mobile device
      #
      # @api public
      # @example POST /api/v1/registration
      # @return void
      def create
        user = build_resource(auth_options)
        if user.save
          respond_with_new_user(user)
        else
          render_api_error(:unprocessable_entity, errors: user.errors.details)
        end
      end

      protected

      # Creates a new user from access parameters
      # @api private
      # @return [User] a new User with params loaded from the current session
      def build_resource(hash = nil)
        resource_class.new_with_session(hash || {}, {})
      end

      # Checks if the user can sign in, and provides an authentication_token to do so
      # @api private
      # @return void
      def respond_with_new_user(user)
        if user.active_for_authentication?
          token = Tiddle.create_and_return_token(user, request)
          render json: { authentication_token: token }
        else
          message = t(:"signed_up_but_#{user.inactive_message}", scope: 'devise.registrations')
          render_api_error(:unauthorized, error: message)
        end
      end

      # Returns a sanitized params hash including all values safe for Devise registration
      # @api private
      # @return [Hash] Returns safe params for Devise registration
      def auth_options
        devise_parameter_sanitizer.sanitize(:sign_up)
      end

      # [Devise] Returns the class used by Devise for authentication
      #
      # Hard coded to accept the User model
      #
      # @api private
      # @return [Class] returns a {User} class
      def resource_class
        User
      end

      # [Devise] Returns the instance name used by Devise for authentication
      #
      # Hard coded to accept the User model
      #
      # @api private
      # @return [String] returns a 'user' string
      def resource_name
        'user'
      end

      # Adds User#name to the list of valid registration params
      # @api private
      # @return void
      def add_registration_params
        devise_parameter_sanitizer.for(:sign_up) << [:name]
      end
    end
  end
end
