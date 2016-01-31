module Concerns
  # Provides #request_body_as_json helper method (for non application/json requests with json)
  module RequestBodyAsJson
    protected

    # Converts the request body into a form encodeable by json
    #
    # Any errors in parsing the response notifies Rollbar
    #
    # @api private
    # @return [Hash] returns a JSON encodeable Hash
    def request_body_as_json
      @request_body_as_json ||=
        begin
          JSON.parse(request_body_as_string)
        rescue JSON::ParserError => e
          Rollbar.error(e, use_exception_level_filters: true)
          { body: request_body_as_string }
        end
    end

    # Converts an Rack-compatable request body into a string
    #
    # @api private
    # @return [String] request.body as a string
    def request_body_as_string
      @request_body_as_string ||=
        begin
          request.body.rewind
          request.body.read
        end
    end
  end
end
