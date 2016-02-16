module Security
  # Handles Reports received from Content Security Policy Violations
  class CspReportsController < Security::ApplicationController
    # Accepts a failed Content Security Policy Report
    #
    # @api public
    # @example POST /security/csp_report
    # @return void
    def create
      Security::ReportMailer.csp_report(csp_report_param).deliver_later(queue: :mailer)

      render text: ''
    end

    protected

    # The CSP Report from the server
    #
    # @api private
    # @return [Hash] the CSP Report param
    def csp_report_param
      @csp_report_param = request_body_as_json.fetch('csp-report', request_body_as_json)
    end
  end
end
