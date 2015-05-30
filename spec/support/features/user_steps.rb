module Features
  module UserSteps
    # Creates an admin and signs them into the app
    def login_admin
      password = Faker::Internet.password
      with_versioning do
        @logged_in_user = create(:user, :admin, password: password, password_confirmation: password)
      end
      sign_in_with_credentials(@logged_in_user.email, password)
    end

    # Creates a user and signs them into the app
    def login_user
      password = Faker::Internet.password
      with_versioning do
        @logged_in_user = create(:user, password: password, password_confirmation: password)
      end
      sign_in_with_credentials(@logged_in_user.email, password)
    end

    # Visits the new session path and signs in using `username` and `password`.
    # The logged in user should normally appear at the Dashboard
    def sign_in_with_credentials(username, password)
      visit new_user_session_path
      fill_in 'user_email', with: username
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end

    # The currently logged in user
    def logged_in_user
      @logged_in_user || fail('User has not been assigned')
    end
  end
end

# Allow known CDN urls to connect to the outside world
RSpec.configure do |config|
  config.include(Features::UserSteps, type: :feature)

  # Adding a :login_admin tag will create and sign in a admin before each scenario
  config.before(:each, login_admin: true) { login_admin }

  # Adding a :login_user tag will create and sign in a user before each scenario
  config.before(:each, login_user: true) { login_user }
end
