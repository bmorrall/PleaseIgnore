module Features
  module NavigationSteps
    def navigate_to_my_profile
      within 'nav.navbar' do
        if page.has_selector?('nav.navbar a', text: t('layouts.navigation.my_dashboard'))
          # Escape from static pages
          click_link t('layouts.navigation.my_dashboard')
        end
        click_link logged_in_user.name
        click_link t('layouts.navigation.my_profile')
      end
    end
  end
end

# Allows Navigation to common pages
RSpec.configure do |config|
  config.include(Features::NavigationSteps, type: :feature)
end
