module CoreExtensions
  module PaperTrail
    # Adds an item_owner assocation to versions,
    # allows for easy grouping of changes to an item and it's associated objects
    module VersionItemOwner
      extend ActiveSupport::Concern

      included do
        belongs_to :item_owner, polymorphic: true
      end
    end
  end
end
