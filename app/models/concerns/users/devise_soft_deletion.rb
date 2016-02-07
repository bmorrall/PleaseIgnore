module Concerns
  module Users
    # Prevents devise from authenticating soft deleted users
    module DeviseSoftDeletion
      extend ActiveSupport::Concern

      included do
        scope :expired, -> { deleted.where('users.deleted_at < ?', 2.months.ago) }

        # [Devise] Ensure user account is active
        def active_for_authentication?
          super && !deleted?
        end

        # [Devise] Provide a custom message for a soft deleted account
        def inactive_message
          !deleted? ? super : :deleted_account
        end
      end

      def expired?
        deleted_at? && deleted_at < 2.months.ago
      end
    end
  end
end
