# Alerts Helper
# Helper methods for displaying flash alerts
module AlertHelper
  # Displays a flash message as a banner alert
  #
  # @param name [String] type of the alert
  # @param message [String} message to display with alert]
  # @yield uses block as message if provided
  # @return message or block as a Boostrap 3 alert
  def display_alert(name, message = nil, &block)
    message ||= html_escape(capture_haml(&block)) if block_given?

    content_tag :div, id: "flash_#{name}", class: alert_class(name) do
      [
        alert_dismiss_button,
        alert_decoration(name),
        content_tag(:strong, message)
      ].join.html_safe
    end
  end

  # Link for dismissing assocated alert
  def alert_dismiss_button
    content_tag(
      :button, '&times;'.html_safe,
      type: 'button',
      class: 'close',
      data: { dismiss: 'alert' },
      'aria-hidden' => 'true'
    )
  end

  # Returns true if `name` matches known flash types
  def should_display_alert?(name, message)
    message.is_a?(String) && !message.blank? &&
      %w(success notice warning alert danger info).include?(name)
  end

  protected

  # Extra icons for displaying next to alert messages
  #
  # @param name [String] name of the alert type
  # @return a font awesome icon based off the alert type
  def alert_decoration(name)
    case name.to_s
    when /notice|success/
      fa 'check'
    when /danger|alert/
      fa 'exclamation-circle'
    when /warning/
      fa 'exclamation-triangle'
    when /info/
      fa 'comment'
    end
  end

  # Class used for alert element
  # Includes:
  # - Bootstrap alert wrapper
  # - Bootstrap JS alert dismiss
  # - FadeInDown CSS animation
  #
  # @param name [String] name of the alert type
  def alert_class(name)
    alert_class = alert_suffix(name.to_s)
    "alert alert-#{alert_class} alert-dismissable animated fadeInDown"
  end

  # Bootstrap alert suffix for alert element class
  #
  # @param name [String] name of the alert type
  def alert_suffix(name)
    case name.to_s
    when /success|notice/
      'success'
    when /danger|alert/
      'danger'
    when /warning/
      'warning'
    when /info/
      'info'
    end
  end
end
