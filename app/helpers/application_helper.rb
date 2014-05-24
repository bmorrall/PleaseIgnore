module ApplicationHelper
  # Cache

  # Ensure cache is cleared after an hour (to prevent issues)
  def default_cache_params
    { expires_in: 1.hour }
  end

  # Header

  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

  # Icons

  def fa(icon_name)
    content_tag :i, nil, class: "fa fa-#{icon_name}"
  end

  # Links

  # Link is external and should not be linked
  def external_link(name = nil, options = nil, html_options = nil, &block)
    extra_options = { rel: 'external' }
    if block_given?
      options = (options || {}).merge(extra_options)
    else
      html_options = (html_options || {}).merge(extra_options)
    end
    link_to(name, options, html_options, &block)
  end

  # Link is to a critical tasks and should not be turbolinked or followed by robots
  def system_link(name = nil, options = nil, html_options = nil, &block)
    extra_options = { rel: 'nofollow', 'data-no-turbolink' => true }
    if block_given?
      options = (options || {}).merge(extra_options)
    else
      html_options = (html_options || {}).merge(extra_options)
    end
    link_to(name, options, html_options, &block)
  end
end
