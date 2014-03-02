module Concerns
  # Allows Content For to be used in Controllers
  # Allows complex params to be set by controllers, and action caching without layout to work
  module ContentForLayout
    extend ActiveSupport::Concern

    included do

      protected

      # FORCE to implement content_for in controller
      def view_context
        super.tap do |view|
          (@_content_for_layout || {}).each do |name,content|
            view.content_for name, content
          end
        end
      end

      # Add content_for into the controller
      def content_for_layout(name, content) # no blocks allowed yet
        @_content_for_layout ||= {}
        if @_content_for_layout[name].respond_to?(:<<)
          @_content_for_layout[name] << content
        else
          @_content_for_layout[name] = content
        end
      end
      def content_for_layout?(name)
        @_content_for_layout[name].present?
      end
    end
  end
end
