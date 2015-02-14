RSpec.configure do |config|
  module TranslationMacros
    def application_name
      t('application.name')
    end
  end

  config.include AbstractController::Translation # Add t() translation helper
  config.include TranslationMacros
end
