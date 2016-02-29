module Concerns
  module Versions
    # Adds PaperTrail Versioning to the Role model
    module RoleVersioning
      extend ActiveSupport::Concern

      included do
        # Add PaperTrail Versioning, only for unexpected event types
        has_paper_trail(
          on: [:update],
          meta: {
            item_owner: :item_owner
          }
        )
      end

      def item_owner
        resource
      end
    end
  end
end
