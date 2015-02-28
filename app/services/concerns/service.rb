module Concerns
  # Adds .call class method, that:
  # - creates a new instance with arguments,
  # - invokes #call on the new instance
  module Service
    extend ActiveSupport::Concern

    included do
      def self.call(*args)
        new(*args).tap(&:call)
      end
    end
  end
end
