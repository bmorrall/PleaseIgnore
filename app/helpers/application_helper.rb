# Application Helper
#
# Provides common helpers for layout
module ApplicationHelper
  # Returns the translated Application Name of the app
  def application_name
    @application_name ||= t('application.name')
  end

  # Cache

  # Ensure cache is cleared after an hour (to prevent issues)
  def default_cache_params
    { expires_in: 1.hour }
  end

  # Header

  # returns active class if navigation item is a link to the current page.
  #
  # @param path [String] Path of Navigation Item
  #
  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

  # Renders header meta tag.
  #
  # @param name [String] name of the meta tag
  # @param content [String] content value of the string
  # @return meta tag with name and content, or an empty string if content is not provided
  def meta_tag(name, content)
    tag :meta, name: name, content: content unless content.blank?
  end

  # Icons

  # Displays a Font Awesome icon in a non semantic tag.
  #
  # @param icon_name [String] icon name without the fa- previx
  # @see http://fortawesome.github.io/Font-Awesome/icons/
  def fa(icon_name)
    content_tag :i, nil, class: "fa fa-#{icon_name}"
  end

  # Links

  # Renders a external link that should not be followed by TurboLinks
  #
  #   link_to "Google", 'http://www.google.com'
  #   # => <a href=http://www.google.com" rel="external">Google</a>
  #
  # @param name [String] UrlHelper#link_to name param
  # @param options [Hash, String] UrlHelper#link_to options param
  # @param html_options [Hash, nil] UrlHelper#link_to html_options param
  # @yield block is passed to UrlHelper#link_to
  # @see http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to
  # @return a link with rel=external attributes
  def external_link(name = nil, options = nil, html_options = nil, &block)
    extra_options = { rel: 'external' }
    if block_given?
      options = (options || {}).merge(extra_options)
    else
      html_options = (html_options || {}).merge(extra_options)
    end
    link_to(name, options, html_options, &block)
  end

  # Renders a link to a critical task and should not be followed by TurboLinks or robots
  #
  #   link_to "My Profile", edit_user_registration_path
  #   # => <a href=/users/edit" rel="nofollow" data-no-turbolink>My Profile</a>
  #
  # @param name [String] UrlHelper#link_to name param
  # @param options [Hash, String] UrlHelper#link_to options param
  # @param html_options [Hash, nil] UrlHelper#link_to html_options param
  # @yield block is passed to UrlHelper#link_to
  # @return a link with rel=nofollow and data-no-turbolink attributes
  # @see http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to
  def system_link(name = nil, options = nil, html_options = nil, &block)
    extra_options = { rel: 'nofollow', 'data-no-turbolink' => true }
    if block_given?
      options = (options || {}).merge(extra_options)
    else
      html_options = (html_options || {}).merge(extra_options)
    end
    link_to(name, options, html_options, &block)
  end

  # Utilities

  def date_is_today?(date)
    date == DateTime.now.to_date
  end

  def date_is_recent?(date)
    date > 1.day.ago
  end
end
