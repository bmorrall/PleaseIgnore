module Concerns
  module Users
    # Prevents devise from authenticating soft deleted users
    module DeviseSoftDeletion
      extend ActiveSupport::Concern

      included do
        # [Devise] Ensure user account is active
        def active_for_authentication?
          super && !deleted?
        end

        # [Devise] Provide a custom message for a soft deleted account
        def inactive_message
          !deleted? ? super : :deleted_account
        end
      end
    end
  end
end
