module CoreExtensions
  module PaperTrail
    # Add meta attributes onto version table
    module VersionMetaStore
      extend ActiveSupport::Concern

      included do
        store :meta, accessors: [:ip, :user_agent, :comments], coder: JSON
      end
    end
  end
end
