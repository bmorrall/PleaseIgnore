module Security
  # Sends a HTTP Public Key Pinning Violation Report to Support
  class ReportMailer < ActionMailer::Base
    include SendGrid
    sendgrid_category 'Security Report'
    default from: proc { ::Settings.security_email_address },
            to: proc { ::Settings.security_email_address }

    add_template_helper(ApplicationHelper)

    # Sends a email notifing security that a CSP Violation has occured
    #
    # Subject can be set with the following lookup: en.security.report_mailer.csp_report.subject
    #
    # @api public
    # @example Security::ReportMailer.csp_report({...}).deliver_now
    # @param csp_report [Hash] a JSON parseable payload
    # @return [ActionMailer::MessageDelivery]
    def csp_report(csp_report)
      @csp_report = csp_report

      mail
    end

    # Sends a email notifing security that a HPKP Violation has occured
    #
    # Subject can be set with the following lookup: en.security.report_mailer.hpkp_report.subject
    #
    # @api public
    # @example Security::ReportMailer.hpkp_report({...}).deliver_now
    # @param csp_report [Hash] a JSON parseable payload
    # @return [ActionMailer::MessageDelivery]
    def hpkp_report(hpkp_report)
      @hpkp_report = hpkp_report

      mail
    end
  end
end
