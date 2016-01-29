module Security
  # Sends a HTTP Public Key Pinning Violation Report to Support
  class HpkpReportMailer < ActionMailer::Base
    include SendGrid
    sendgrid_category :use_subject_lines
    default from: proc { ::Settings.security_email_address },
            to: proc { ::Settings.security_email_address }

    add_template_helper(ApplicationHelper)

    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.security.hpkp_reports.support_email.subject
    #
    def support_email(hpkp_report)
      sendgrid_category 'Security Email'
      @hpkp_report = hpkp_report

      mail
    end
  end
end
