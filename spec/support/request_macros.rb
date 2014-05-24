module RequestMacros
  module ClassMethods
    def login_user
      before(:each) do
        @logged_in_user = FactoryGirl.create(:user)
        post new_user_session_path, user: { email: @logged_in_user.email, password: 'changeme' }
      end
    end
  end

  def logged_in_user
    fail 'No user logged in' if @logged_in_user.nil?
    @logged_in_user
  end

  def self.included(request_spec)
    request_spec.extend(ClassMethods)
  end
end
