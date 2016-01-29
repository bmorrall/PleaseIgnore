module Security
  # Sends a HTTP Public Key Pinning Violation Report to Support
  class ReportMailer < ActionMailer::Base
    include SendGrid
    sendgrid_category 'Security Report'
    default from: proc { ::Settings.security_email_address },
            to: proc { ::Settings.security_email_address }

    add_template_helper(ApplicationHelper)

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.security.report_mailer.hpkp_report.subject
    #
    def hpkp_report(hpkp_report)
      @hpkp_report = hpkp_report

      mail
    end
  end
end
