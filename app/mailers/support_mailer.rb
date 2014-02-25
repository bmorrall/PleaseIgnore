class SupportMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default to: "support@pleaseignore.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.support_mailer.contact_email.subject
  #
  def contact_email(attributes)
    sendgrid_category 'Contact Email'
    @contact = Contact.new(attributes)

    mail from: "contact@pleaseignore.com", subject: 'PleaseIgnore Contact Email'
  end
end
