# Provides helper methods for evaluating paths
module NavigationHelpers
  def current_host_with_port
    host = current_host
    port = Capybara.current_session.server.nil? ? nil : Capybara.current_session.server.port
    if host =~ /\:\d+$/ || port.nil? || port == '80'
      host
    else
      "#{host}:#{port}"
    end
  end

  # rubocop:disable CyclomaticComplexity, MethodLength

  # Maps a name to a path. Used by the
  #
  #   When %r{^I go to (.+)$} do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the sign up page/
      '/users/sign_up'

    when /the sign in page/
      '/users/sign_in'

    when /the privacy policy page/
      '/privacy'

    when /the terms of service page/
      '/terms'

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (?<page>.*) page/
        path_components = page.split(/\s+/)
        send(path_components.push('path').join('_').to_sym)
      rescue Object
        raise "Can't find mapping from \"#{page_name}\" to a path.\n"\
              "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
  # rubocop:enable CyclomaticComplexity, MethodLength
end

World(NavigationHelpers)
