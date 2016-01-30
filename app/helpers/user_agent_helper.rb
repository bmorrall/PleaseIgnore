# Adds Tags for Displaying User Agents and IP Addresses
module UserAgentHelper
  # Renders a pretty html tag for displaying an ip address, with js geocoding
  #
  # @api public
  # @example <%= ip_address_tag '127.0.0.1' %>
  # @param string [String] IPv4 address to be displayed
  # @return a geocode-able html tag displaying an ip address
  def ip_address_tag(string)
    return unless string

    content_tag :span, title: "IP: #{string}", class: 'ip-address' do
      [
        fa('globe'),
        content_tag(:span, string, data: { geocode_ip: string })
      ].join.html_safe
    end
  end

  # Displays a pretty user agent string, pretty printing browser and device details
  #
  # @api public
  # @example <%= user_agent_tag 'Mozilla/5.0 (Googlebot/2.1)' %>
  # @param string [String] User Agent Tag to be pretty displayed
  # @return a tag containing a cleaned up user agent tag and a device icon
  def user_agent_tag(string)
    return unless string

    user_agent = UserAgent.parse(string)
    content_tag :span, title: string, class: 'user-agent' do
      [
        user_agent_icon(user_agent),
        html_escape("#{user_agent.browser} #{user_agent.version} (#{user_agent.os})")
      ].join.html_safe
    end
  end

  # Returns a font-awesome icon representing the user agent
  #
  # @api public
  # @example <%= user_agent_icon 'Mozilla/5.0 (Googlebot/2.1)' %>
  # @param string [String] User Agent Tag to be assocated with an icon
  # @return a tag rendering a font-awesome icon representation of the user agent
  def user_agent_icon(user_agent)
    image =
      if user_agent.bot?
        'bug'
      elsif user_agent.mobile?
        mobile_user_agent_icon_image(user_agent)
      else
        desktop_user_agent_icon_image(user_agent)
      end
    fa(image)
  end

  protected

  # Finds a relevant font-awesome icon name or defaults to a generic desktop
  #
  # @api private
  # @return [String] FontAwesome Icon used to represent the User Agent's Desktop Operating System
  def desktop_user_agent_icon_image(user_agent)
    platform_icon_image(user_agent) || 'desktop'
  end

  # Finds a relevant font-awesome icon name or defaults to a generic mobile
  #
  # @api private
  # @return [String] FontAwesome Icon used to represent the User Agent's Mobile Operating System
  def mobile_user_agent_icon_image(user_agent)
    platform_icon_image(user_agent) || 'mobile'
  end

  # rubocop:disable Metrics/MethodLength

  # Attempts to return a font-awesome icon name representing the user agent, or nil
  #
  # @api private
  # @return [String] FontAwesome icon representing a known Operating System or nil
  def platform_icon_image(user_agent)
    case user_agent.os
    when /Android/
      'android'
    when /iOS/
      'apple'
    when /Linux/
      'linux'
    when /OS X/
      'laptop'
    when /Windows/
      'windows'
    end
  end

  # rubocop:enable Metrics/MethodLength
end
