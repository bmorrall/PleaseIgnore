module Api
  module V1
    # Base Controller class for Api::V1 Controllers
    class ApplicationController < ::ActionController::Base
      # Prevent CSRF attacks by clearning the session..
      protect_from_forgery with: :null_session

      before_action :destroy_session

      protected

      # Prevents the API from setting anything to the session
      def destroy_session
        request.session_options[:skip] = true
      end

      # [PaperTrail] include IP and User Agent in version history
      def info_for_paper_trail
        {
          ip: request.remote_ip,
          user_agent: request.user_agent
        }
      end

      # Renders a standard error response back to the user
      def render_api_error(status, error_body = {})
        status_number =
          case status
          when Symbol
            Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
          else
            status.to_i
          end
        render json: error_body.merge(status: status_number), status: status
      end
    end
  end
end
