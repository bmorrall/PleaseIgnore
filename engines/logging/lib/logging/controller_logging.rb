module Logging
  # Extensions for Lograge Logging info
  module ControllerLogging
    extend ActiveSupport::Concern

    included do
      # Allows ip, user_agent and current user info to be added to logs
      def append_info_to_payload(payload)
        super

        payload.merge(event_payload_data)
      end
    end

    def event_payload_data
      {}.tap do |payload|
        # Client params
        payload[:ip] = request.remote_ip
        payload[:user_agent] = request.user_agent
        payload[:request_id] = request.env['action_dispatch.request_id']

        # Logged in user params
        if respond_to?(:user_signed_in?) && user_signed_in?
          payload[:user] = current_user.name
          payload[:user_id] = current_user.id
        end
      end
    end
  end
end
