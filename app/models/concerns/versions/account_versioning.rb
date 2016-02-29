module Concerns
  module Versions
    # Adds PaperTrail Versioning to the Account model
    module AccountVersioning
      extend ActiveSupport::Concern

      included do
        # Use paper_trail to track changes to unexpected values
        has_paper_trail(
          only: [
            :user_id,
            :type
          ],
          ignore: [
            :name,
            :nickname,
            :image,
            :website,
            :deleted_at
          ],
          meta: {
            item_owner: :item_owner
          }
        )

        # Allow soft_deletion restore events to be logged
        include Concerns::RecordRestore

        # Create Restore paper_trail version if a record is restored
        after_restore do
          record_restore
          user.touch # Ensure the user is touched
        end
      end

      # All accounts belong to a user
      def item_owner
        user
      end
    end
  end
end
