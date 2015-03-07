module CoreExtensions
  module EmailPrefixer
    # Prepend locale-translated application name to email subjects
    module TranslatedApplicationName
      def application_name
        I18n.t('application.name')
      end
    end
  end
end
EmailPrefixer.configuration.extend CoreExtensions::EmailPrefixer::TranslatedApplicationName
