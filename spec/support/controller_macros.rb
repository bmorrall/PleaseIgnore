# Provides common macros for controller specs
module ControllerMacros
  # Class Methods methods can be called directly from the class
  module ClassMethods
    def login_user
      before(:each) do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        @logged_in_user = create(:user)
        sign_in @logged_in_user
      end
    end

    def grant_ability(ability, object)
      before(:each) { @ability.can ability, object }
    end
  end

  # Authentication Methods

  def logged_in_user
    @logged_in_user || fail('No user logged in')
  end

  # Authorization Methods

  attr_reader :ability

  def self.included(controller_spec)
    controller_spec.extend(ClassMethods)

    # Stub out Abilities
    controller_spec.before(:each) do
      @ability = Object.new
      @ability.extend(CanCan::Ability)
      allow(controller).to receive(:current_ability).and_return(@ability)
    end
  end
end

RSpec.configure do |config|
  config.include ControllerMacros, type: :controller
end
