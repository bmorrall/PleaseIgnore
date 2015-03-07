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

  # returns active class if navigation item is a link to the current page.
  #
  # @param path [String] Path of Navigation Item
  #
  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end
end
