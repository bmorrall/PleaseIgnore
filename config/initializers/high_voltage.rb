HighVoltage.configure do |config|
  # Disable Routes to HighVoltage::PageController
  config.routes = false

  # Use Action Caching
  config.action_caching = true

  # but not for layout
  config.action_caching_layout = false
end
