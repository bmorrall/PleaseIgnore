RSpec.configure do |config|
  module ViewMacros
    module AuthenticatedView
      def current_ability
        @current_ability ||= Object.new.tap { |o| o.extend(CanCan::Ability) }
      end
    end
  end

  config.before(:each, type: :view) do
    # Stub in cache_uid, provided by ApplicationController
    skip_double_verification do
      allow(view).to receive(:cache_uid).and_return(:v1)
    end
  end

  config.before(:each, authenticated_view: true) do
    allow(controller).to receive(:current_ability).and_return(current_ability)
  end
  config.include ViewMacros::AuthenticatedView, authenticated_view: true
end
