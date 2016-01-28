# Layout Helper
#
# Provides common helpers for layout
module LayoutHelper
  # Page Head

  # blank CSRF tags that allow for pages to be statically cached
  def static_csrf_meta_tags
    [
      tag('meta', name: 'csrf-param', content: request_forgery_protection_token),
      tag('meta', name: 'csrf-token', content: '')
    ].join("\n").html_safe
  end

  # Renders header meta tag.
  #
  # @param name [String] name of the meta tag
  # @param content [String] content value of the string
  # @return meta tag with name and content, or an empty string if content is not provided
  def meta_tag(name, content)
    tag :meta, name: name, content: content unless content.blank?
  end

  # Header

  # Returns active class if navigation item is a link to the current page.
  #
  # @param paths [String, Array] Paths where Navigation Item should be active
  #
  def header_nav_class(*paths)
    paths.any? { |path| current_page?(path) } ? 'active' : nil
  end

  # External Services

  # @return [Boolean] true if user should see list of external services
  def display_external_services?
    current_user.has_role?(:admin) && (
      display_sidekiq_service_link?
    )
  end

  # @return [Boolean] true if user should see link to sidekiq service
  def display_sidekiq_service_link?
    ::Settings.redis_url.present?
  end

  # Forms

  # Default Params for Horizontal Forms
  def horizontal_bootstrap_defaults
    { label_html: { class: 'col-sm-3' } }
  end

  # Default Params for Wide Horizontal Forms
  def horizontal_bootstrap_wide_defaults
    { label_html: { class: 'col-sm-2' } }
  end
end
