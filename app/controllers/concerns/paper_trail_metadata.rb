module Concerns
  # Extensions for Lograge Logging info
  module PaperTrailMetadata
    extend ActiveSupport::Concern
    included do
      # Appends email address to whodunnit
      def user_for_paper_trail
        user_signed_in? ? "#{current_user.id} #{current_user.email}" : nil
      end
    end
  end
end
