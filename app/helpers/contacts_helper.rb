# Contacts Helper
# Helper methods for Contacts page
module ContactsHelper
  # @param [Symbol] field_name name of field that could render autofocus
  # @return [Boolean] true, if contact should autofocus on `field_name`
  def contact_autofocus_input?(field_name)
    field_name == autofocus_field
  end

  protected

  # @return [Symbol] returns the field that should have autofocus
  def autofocus_field
    if @contact.name.blank?
      :name
    elsif @contact.email.blank?
      :email
    else
      :body
    end
  end
end
