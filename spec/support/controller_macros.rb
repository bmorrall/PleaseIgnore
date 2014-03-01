module ControllerMacros

  module ClassMethods

    def login_user
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @logged_in_user = FactoryGirl.create(:user)
        sign_in @logged_in_user
      end
    end

  end

  def logged_in_user
    raise 'No user logged in' if @logged_in_user.nil?
    @logged_in_user
  end

  def self.included(controller_spec)
    controller_spec.extend(ClassMethods)
  end

end
