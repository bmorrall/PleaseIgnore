# Support Mailer
# Mailer used to contact support for various issues
#
# - Sends Contact Request email
class SupportMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default to: Rails.application.secrets.support_email_address

  add_template_helper(ApplicationHelper)

  # Sends a Contact Request to Support
  #
  # @param attributes [Hash] Contact attributes to send to support
  def contact_email(attributes)
    sendgrid_category 'Contact Email'
    @contact = Contact.new(attributes)

    mail from: Rails.application.secrets.contact_email_address
  end
end
