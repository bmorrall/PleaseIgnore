module Features
  module AdminUser
    def login_admin
      password = 'password123' || Faker::Internet.password
      @admin = create(:user, :admin, password: password, password_confirmation: password)

      visit new_user_session_path
      fill_in 'user_email', with: @admin.email
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end

    def admin_user
      @admin || fail('Admin has not been assigned')
    end
  end
end

# Allow known CDN urls to connect to the outside world
RSpec.configure do |config|
  config.include(Features::AdminUser, type: :feature, admin: true)
end
