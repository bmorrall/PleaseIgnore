module Security
  # Handles Reports received from Content Security Policy Violations
  class CspReportsController < ApplicationController
    # Prevent CSRF attacks by clearning the session..
    protect_from_forgery with: :null_session

    # Don't check for permissions
    skip_authorization_check

    # Accepts a failed Content Security Policy Report
    #
    # @api public
    # @example POST /security/csp_report
    # @return void
    def create
      Security::ReportMailer.csp_report(parsed_csp_report).deliver_later(queue: :mailer)

      render text: ''
    end

    protected

    # Converts the request body into a form parseable by json
    #
    # Any errors in parsing the response notifies Rollbar
    #
    # @api private
    # @return [String] returns either a JSON parseable reponse string
    def parsed_csp_report
      JSON.parse(request.body.string)
    rescue JSON::ParserError => e
      Rollbar.error(e)
      [request.body.string]
    end
  end
end
