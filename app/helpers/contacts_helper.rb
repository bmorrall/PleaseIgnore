module ContactsHelper

  def contact_autofocus(param)
    case param
    when :name
      @contact.name.blank?
    when :email
      !@contact.name.blank? && @contact.email.blank?
    when :body
      !@contact.name.blank? && !@contact.email.blank?
    end
  end

end
