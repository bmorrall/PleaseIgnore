module CoreExtensions
  module String
    # Adds Convenience method #safe_permalink to string, which:
    # - downcases, strips non-ascii characters
    # - converts invalid characters to single '-' strings
    module SafePermalink
      # Converts string into a safe permalink, relies on #transliterate
      # @api public
      # @example "JÃ¼rgen Borscht".safe_permalink => "jurgen-borscht"
      # @return [String] a string safe to use as a permalink
      def safe_permalink
        # permalink has characters normalised from non-latin characters
        transliterate.tap do |permalink|
          permalink.scrub!('-') # Remove remaining non utf-8 characters
          permalink.downcase! # Downcase all values
          permalink.gsub!(/[^a-z0-9]+/, '-') # Replace duplicate invalid characters with single '-'
          permalink.sub!(/\A-/, '') # Remove any leading '-' characters
          permalink.chomp!('-') # Remove any trailing '-' characters
        end
      end
    end
  end
end
