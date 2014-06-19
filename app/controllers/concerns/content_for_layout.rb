module Concerns
  # Allows Content For to be used in Controllers
  # Allows complex params to be set by controllers, and action caching without layout to work
  module ContentForLayout
    extend ActiveSupport::Concern

    included do

      protected

      # Sets the page title
      def page_title(page_title)
        content_for_layout :page_title, page_title
      end

      # Sets the page author
      def page_author(author)
        content_for_layout :meta_author, author
      end

      # Sets the page description
      def page_description(description)
        content_for_layout :meta_description, description
      end

      # Adds extra classes to the page body
      def extra_body_classes(extra_body_classes)
        content_for_layout :extra_body_classes, extra_body_classes
      end

      # FORCE to implement content_for in controller
      def view_context
        super.tap do |view|
          (@_content_for_layout || {}).each do |name, content|
            view.content_for name, content
          end
        end
      end

      private

      # Add content_for into the controller
      def content_for_layout(name, content) # no blocks allowed yet
        @_content_for_layout ||= {}
        if @_content_for_layout[name].respond_to?(:<<)
          @_content_for_layout[name] << ' ' << content
        else
          @_content_for_layout[name] = content
        end
      end
    end
  end
end
