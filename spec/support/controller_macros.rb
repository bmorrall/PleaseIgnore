module ControllerMacros

  module ClassMethods

    def login_user
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @logged_in_user = FactoryGirl.create(:user)
        sign_in @logged_in_user
      end
    end

    def grant_ability(ability, object)
      before(:each) { @ability.can ability, object }
    end
  end

  # Authentication Methods

  def logged_in_user
    @logged_in_user || raise('No user logged in')
  end

  # Authorization Methods

  def ability
    @ability
  end

  def self.included(controller_spec)
    controller_spec.extend(ClassMethods)

    # Stub out Abilities
    controller_spec.before(:each) do
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      controller.stub(:current_ability).and_return(@ability)
    end
  end

end
