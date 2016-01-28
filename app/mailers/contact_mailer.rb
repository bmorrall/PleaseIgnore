require 'settings'

# Contact Mailer
# Mailer used by the Contact controller
#
# - Sends Contact Request email to support
class ContactMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  default from: proc { ::Settings.contact_email_address }

  add_template_helper(ApplicationHelper)

  # Sends a Contact Request to Support
  #
  # @param attributes [Hash] Contact attributes to send to support
  def support_email(attributes)
    sendgrid_category 'Contact Email'
    @contact = Contact.new(attributes)

    mail to: ::Settings.support_email_address
  end
end
