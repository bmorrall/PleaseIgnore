module AlertHelper

  def display_alert(name, message)
    content_tag :div, id: "flash_#{name}", class: alert_class(name) do
      [
        alert_dismiss_button,
        alert_decoration(name),
        content_tag(:strong, message)
      ].join.html_safe
    end
  end

  def alert_class(name)
    alert_class = case name.to_s
    when /success|notice/
      'success'
    when /danger|alert/
      'danger'
    when /warning/
      'warning'
    when /info/
      'info'
    end
    "alert alert-#{alert_class} alert-dismissable animated fadeInDown"
  end

  def alert_dismiss_button
    content_tag(:button, '&times;'.html_safe,
      type: "button",
      class: "close",
      data: { dismiss: "alert" },
      'aria-hidden' => "true"
    )
  end

  def alert_decoration(name)
    case name.to_s
    when /notice|success/
      fa 'check'
    end
  end

  def should_display_alert?(name, message)
    message.is_a?(String) && 
      %w(success notice warning alert danger info).include?(name)
  end

end