module DeviseMacros
  # Adds Devise View Context to Models
  def stub_devise_mappings
    skip_double_verification do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
    end
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
  config.include DeviseMacros, type: :view
end
