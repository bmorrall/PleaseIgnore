# Adds Tags for Displaying User Agents and IP Addresses
module UserAgentHelper
  def ip_address_tag(string)
    return unless string

    content_tag :span, title: "IP: #{string}" do
      [
        fa('globe'),
        content_tag(:span, string, data: { geocode_ip: string })
      ].join.html_safe
    end
  end

  def user_agent_tag(string)
    return unless string

    user_agent = UserAgent.parse(string)
    content_tag :span, title: string do
      [
        user_agent_icon(user_agent),
        html_escape("#{user_agent.browser} #{user_agent.version} (#{user_agent.os})")
      ].join.html_safe
    end
  end

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

  def desktop_user_agent_icon_image(user_agent)
    case user_agent.os
    when /Windows/
      'windows'
    when /Linux/
      'linux'
    when /OS X/
      'laptop'
    else
      'desktop'
    end
  end

  def mobile_user_agent_icon_image(user_agent)
    case user_agent.os
    when /Android/
      'android'
    when /iOS/
      'apple'
    else
      'mobile'
    end
  end
end
