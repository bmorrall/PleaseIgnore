module ApplicationHelper

  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

  def message_alert_class(name)
    if name == :notice
      'success'
    elsif name == :warning
      'warning'
    elsif name == :info
      'info'
    else
      'danger'
    end
  end

end
