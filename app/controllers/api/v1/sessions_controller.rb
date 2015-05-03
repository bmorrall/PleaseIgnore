module Api
  module V1
    # Allows Registered Users to create and destroy an access Token
    class SessionsController < Api::V1::ApplicationController
      # POST /api/v1/session
      def create
        auth_options = self.auth_options
        password = auth_options.delete(:password)

        resource = User.find_for_authentication auth_options
        if resource.try(:valid_password?, password)
          token = Tiddle.create_and_return_token(resource, request)
          render json: { authentication_token: token }
        else
          render_api_error(:unauthorized, error: t('devise.failure.invalid'))
        end
      end

      # DELETE /api/v1/session
      def destroy
        Tiddle.expire_token(current_user, request) if user_signed_in?
        render json: {}
      end

      protected

      def auth_options
        devise_parameter_sanitizer.sanitize(:sign_in)
      end

      def resource_class
        User
      end

      def resource_name
        'user'
      end
    end
  end
end
