
# Enables CSRF for a test spec
Around('@csrf_protection') do |_scenario, block|
  current_protection = ApplicationController.allow_forgery_protection
  ApplicationController.allow_forgery_protection = true
  block.call
  ApplicationController.allow_forgery_protection = current_protection
end
