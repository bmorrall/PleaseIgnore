module Api
  module V1
    # Allows Guests to Register a new account via the API
    class RegistrationsController < Api::V1::ApplicationController
      before_action :add_registration_params

      # POST /api/v1/registration
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
      def build_resource(hash = nil)
        resource_class.new_with_session(hash || {}, {})
      end

      # Checks if the user can sign in, and provides an authentication_token to do so
      def respond_with_new_user(user)
        if user.active_for_authentication?
          token = Tiddle.create_and_return_token(user, request)
          render json: { authentication_token: token }
        else
          message = t(:"signed_up_but_#{user.inactive_message}", scope: 'devise.registrations')
          render_api_error(:unauthorized, error: message)
        end
      end

      def auth_options
        devise_parameter_sanitizer.sanitize(:sign_up)
      end

      def resource_class
        User
      end

      def resource_name
        'user'
      end

      def add_registration_params
        devise_parameter_sanitizer.for(:sign_up) << [:name]
      end
    end
  end
end
