module Features
  module UserSteps
    def login_user
      password = 'password123' || Faker::Internet.password
      @current_user = create(:user, password: password, password_confirmation: password)

      visit new_user_session_path
      fill_in 'user_email', with: current_user.email
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end

    def current_user
      @current_user || fail('User has not been assigned')
    end
  end
end

# Allow known CDN urls to connect to the outside world
RSpec.configure do |config|
  config.include(Features::UserSteps, type: :feature, user: true)
end
