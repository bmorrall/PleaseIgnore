# Adds Base Error Messages to SimpleForm ErrorNotification
#
# === How to Use
#
# Requires SimpleForm to be Monkey Patched to override default notification
#
#   module SimpleForm
#     class FormBuilder < ActionView::Helpers::FormBuilder
#       def error_notification(options = {})
#         BaseErrorNotification.new(self, options).render
#       end
#     end
#   end
#
# === Example Output
#
#   user = User.new
#   user.errors.add :base, 'This is a Base Error'
#
#   simple_form_for(user) do |f|
#     f.error_notification
#   end
#   # => <strong>Please review the problems below:</strong>
#   # => <ul>
#   # =>   <li>This is a Base Error</li>
#   # => </ul>
class BaseErrorNotification < SimpleForm::ErrorNotification
  # Overrides SimpleForm::ErrorNotification#error_message to include base error messages
  # as a <ul> list appended to the default error message.
  #
  # Wraps the default message in a <strong> block.
  def error_message
    messages = [template.content_tag(:strong, super)]
    base_errors = object.errors[:base]
    if base_errors.any?
      error_items = base_errors_as_list_items(base_errors)
      messages << template.content_tag(:ul, error_items)
    end
    messages.join.html_safe
  end

  def base_errors_as_list_items(base_errors)
    base_errors.map { |error| template.content_tag :li, error }.join.html_safe
  end
end
