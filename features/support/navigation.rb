# Provides Helpers to Simulate Users moving through the site via menus and links,
# rather than directly entering page urls.
module NavigationHelpers
  # rubocop:disable AbcSize, CyclomaticComplexity, MethodLength

  def navigate_to(page_name)
    # Ensure a at least home page is open
    visit path_to('the home page') unless @current_page

    case page_name

    when /the home\s?page/
      within 'nav.navbar' do
        click_link t('layouts.navbar_items.home')
      end

    when /the sign up page/
      within 'nav.navbar' do
        click_link t('layouts.navigation.my_dashboard')
      end
      click_link t('devise.sessions.new.create_account')

    when /the sign in page/
      within 'nav.navbar' do
        click_link t('layouts.navigation.my_dashboard')
      end

    when /the reset password page/
      navigate_to 'the sign in page'
      click_link 'Forgot password?'

    when /my profile page/
      within 'nav.navbar' do
        if page.has_selector?('nav.navbar a', text: t('layouts.navigation.my_dashboard'))
          # Escape from static pages
          click_link t('layouts.navigation.my_dashboard')
        end
        click_link @visitor[:name]
        click_link t('layouts.navigation.my_profile')
      end

    when /the privacy policy page/
      navigate_to 'the sign up page'
      click_link 'Privacy Policy'
      switch_to_new_tab

    when /the terms of service page/
      navigate_to 'the sign up page'
      click_link 'Terms of Service'
      switch_to_new_tab

    else
      fail "Don't know how to navigate to \"#{page_name}\".\n"\
           "Now, go and add a mapping in #{__FILE__}"
    end

    @current_page = path_to(page_name)
  end

  def switch_to_new_tab
    if page.driver.browser.respond_to? :switch_to
      # Switch tabs when using selenium
      page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    else
      page.driver.switch_to_window page.driver.window_handles.last
    end
  end

  # rubocop:enable AbcSize, CyclomaticComplexity, MethodLength
end

World(NavigationHelpers)
