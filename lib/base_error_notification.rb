# Adds Base Error Messages to Simple Form ErrorNotifcation
class BaseErrorNotification < SimpleForm::ErrorNotification

  def error_message
    messages = [ template.content_tag(:strong, super) ]
    base_errors = object.errors[:base]
    if base_errors.any?
      error_items = base_errors.map { |error| template.content_tag :li, error }
      messages << template.content_tag(:ul, error_items.join.html_safe)
    end
    messages.join.html_safe
  end
end

