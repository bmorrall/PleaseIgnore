module Security
  # Handles Reports received from HTTP Public Key Pinning Violations
  class HpkpReportsController < ApplicationController
    # Prevent CSRF attacks by clearning the session..
    protect_from_forgery with: :null_session

    # Don't check for permissions
    skip_authorization_check

    # Accepts a failed HTTP Public Key Pinning Report
    #
    # @api public
    # @example POST /security/hpkp_report
    # @return void
    def create
      Security::ReportMailer.hpkp_report(parsed_hpkp_report).deliver_later(queue: :mailer)

      render text: ''
    end

    protected

    def parsed_hpkp_report
      JSON.parse(request.body.string)
    rescue JSON::ParserError => e
      Rollbar.error(e)
      [request.body.string]
    end
  end
end
