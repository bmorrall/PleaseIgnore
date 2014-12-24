# Provides common macros for request specs
module RequestMacros
  # Class Methods methods can be called directly from the class
  module ClassMethods
    # Logs a user in for request specs
    def login_user
      before(:each) do
        @logged_in_user = create(:user)
        post new_user_session_path, user: { email: @logged_in_user.email, password: 'changeme' }
      end
    end
  end

  # Accessor for logged in user
  def logged_in_user
    fail 'No user logged in' if @logged_in_user.nil?
    @logged_in_user
  end

  def self.included(request_spec)
    request_spec.extend(ClassMethods)
  end
end

RSpec.configure do |config|
  config.include RequestMacros, type: :request
end
