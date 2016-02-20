require 'logging/controller_params_filter'

module Logging
  # Converts a Metal payload into additional params for logging
  class LogrageEventParser
    attr_reader :default_params

    def initialize(default_params = {})
      @default_params = default_params
    end

    def call(event)
      {
        params: filtered_params(event),

        # Request Params
        ip: event.payload[:ip],
        user_agent: event.payload[:user_agent],
        request_id: event.payload[:request_id],

        # Session Params
        user: event.payload[:user],
        user_id: event.payload[:user_id]
      }.reverse_merge(default_params)
    end

    protected

    def filtered_params(event)
      Logging::ControllerParamsFilter.filter(event.payload[:params])
    end
  end
end
