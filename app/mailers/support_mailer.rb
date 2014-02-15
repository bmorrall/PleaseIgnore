class SupportMailer < ActionMailer::Base
  default to: "support@pleaseignore.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.support_mailer.contact_email.subject
  #
  def contact_email(attributes)
    @contact = Contact.new(attributes)

    mail from: "contact@pleaseignore.com"
  end
end
