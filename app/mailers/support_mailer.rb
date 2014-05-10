class SupportMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default to: Rails.application.secrets.support_email_address

  # Sends a Contact Request to Support
  def contact_email(attributes)
    sendgrid_category 'Contact Email'
    @contact = Contact.new(attributes)

    mail from: Rails.application.secrets.contact_email_address
  end
end
