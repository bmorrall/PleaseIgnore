RSpec.configure do |config|
  config.before(:each, type: :view) do
    # Stub in cache_uid, provided by ApplicationController
    skip_double_verification do
      allow(view).to receive(:cache_uid).and_return(:v1)
    end
  end
end
