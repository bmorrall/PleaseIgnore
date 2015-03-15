RSpec.configure do |config|
  config.around(type: :feature, csrf_protection: true) do |example|
    current_protection = ApplicationController.allow_forgery_protection
    ApplicationController.allow_forgery_protection = true
    example.run
    ApplicationController.allow_forgery_protection = current_protection
  end
end
