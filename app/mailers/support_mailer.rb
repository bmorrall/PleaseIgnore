class SupportMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default to: Rails.application.secrets.support_email_address

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.support_mailer.contact_email.subject
  #
  def contact_email(attributes)
    sendgrid_category 'Contact Email'
    @contact = Contact.new(attributes)

    mail from: Rails.application.secrets.contact_email_address, subject: 'PleaseIgnore Contact Email'
  end
end
