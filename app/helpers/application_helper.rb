# Application Helper
#
# Provides common helpers for application
module ApplicationHelper
  # Cells 3 style cell render call.
  # @param name Name of cell to be rendered
  # @param state Name of view method to be invoked
  # @deprecated use cell(name).call(state) instead
  def render_cell(name, state, *args)
    cell(name).call(state, *args)
  end
  deprecate :render_cell

  # Returns the translated Application Name of the app
  def application_name
    @application_name ||= t('application.name')
  end

  # Cache

  # Ensure cache is cleared after an hour (to prevent issues)
  def default_cache_params
    { expires_in: 1.hour }
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

  # Rendering

  def render_summary
    "<!-- Page generated at #{Time.zone.now.iso8601} -->".html_safe
  end

  # Utilities

  def date_is_today?(date)
    date == DateTime.now.to_date
  end

  def date_is_recent?(date)
    date > 1.day.ago
  end
end
