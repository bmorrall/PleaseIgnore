module Security
  # Handles Reports received from HTTP Public Key Pinning Violations
  class HpkpReportsController < Security::ApplicationController
    # Accepts a failed HTTP Public Key Pinning Report
    #
    # @api public
    # @example POST /security/hpkp_report
    # @return void
    def create
      Security::ReportMailer.hpkp_report(hpkp_report_param)
                            .deliver_later(queue: Workers::HIGH_PRIORITY)

      render text: ''
    end

    protected

    # The Hpkp report received by the server
    #
    # @api private
    # @return [String] returns either a JSON parseable reponse string
    def hpkp_report_param
      @hpkp_report_param ||= request_body_as_json
    end
  end
end
