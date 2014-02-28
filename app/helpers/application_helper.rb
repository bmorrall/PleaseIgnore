module ApplicationHelper

  # Header

  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

  # Icons

  def fa(icon_name)
    content_tag :i, nil, class: "fa fa-#{icon_name}"
  end

  # Alerts

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

  # Links

  # Link is external and should not be linked
  def external_link(name = nil, options = nil, html_options = nil, &block)
    extra_options = {rel: 'external'}
    if block_given?
      options = (options || {}).merge(extra_options)
    else
      html_options = (html_options || {}).merge(extra_options)
    end
    link_to(name, options, html_options, &block)
  end

end
