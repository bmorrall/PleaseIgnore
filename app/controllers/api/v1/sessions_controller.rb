module Api
  module V1
    # Allows Registered Users to create and destroy an access Token
    class SessionsController < Api::V1::ApplicationController
      # Creates a new Authentication token unique to the current device
      #
      # @api public
      # @example DELETE /api/v1/session
      # @return void
      def create
        auth_options = self.auth_options
        password = auth_options.delete(:password)

        resource = User.find_for_authentication auth_options
        if resource.try(:valid_password?, password)
          # Ensure the user doesn't go over their token limit
          Tiddle.purge_old_tokens(resource)

          # Generate and return a new token
          token = Tiddle.create_and_return_token(resource, request)
          render json: { authentication_token: token }
        else
          render_api_error(:unauthorized, error: t('devise.failure.invalid'))
        end
      end

      # Expires the current active Authentication token
      #
      # @api public
      # @example DELETE /api/v1/session
      # @return void
      def destroy
        Tiddle.expire_token(current_user, request) if user_signed_in?
        render json: {}
      end

      protected

      # Returns a sanitized params hash including all values safe for devise authentication
      #
      # @api private
      # @return [Hash] Safe parameters for authentication
      def auth_options
        devise_parameter_sanitizer.sanitize(:sign_in)
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
    end
  end
end
