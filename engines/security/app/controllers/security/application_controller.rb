module Security
  # Provides a Stripped Down ActionController with no session memory
  class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by clearning the session..
    protect_from_forgery with: :null_session

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
          NotifyErrorHandlers.call(e)
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
