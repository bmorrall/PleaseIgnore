require 'i18n'

module CoreExtensions
  module String
    # Adds convenience method to transliterate strings
    module Transliterations
      # Removes accented characters from string by converting them into ASCII
      def transliterate
        I18n.transliterate(self)
      end
    end
  end
end
