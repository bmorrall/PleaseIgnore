module Concerns
  # Extensions for Lograge Logging info
  module LogrageExtensions
    extend ActiveSupport::Concern
    included do
      # Allows ip, user_agent and current user info to be added to logs
      def append_info_to_payload(payload)
        super

        # Request params
        payload[:xhr] = request.xhr?

        # Client params
        payload[:ip] = request.ip
        payload[:user_agent] = request.user_agent

        # Logged in user params
        return unless user_signed_in?
        payload[:user] = current_user.email
        payload[:user_id] = current_user.id
      end
    end
  end
end
