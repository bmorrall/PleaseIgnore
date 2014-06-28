module Concerns
  # Overrides Turboboost errors with a hash that includes form wrapper values.
  module BetterTurboboostErrors
    extend ActiveSupport::Concern

    included do

      # Override Turboboost errors with better messages
      def render_turboboost_errors_for(record)
        messages = {}
        field_prefix = record.class.name.underscore
        record.errors.each do |field, errors|
          messages["#{field_prefix}_#{field}"] = full_error_messages_array(record, field, errors)
        end
        render json: messages, status: :unprocessable_entity, root: false
      end
      hide_action :render_turboboost_errors_for

      protected

      # Adds full error messages array
      def full_error_messages_array(record, field, errors)
        if errors.is_a? Array
          errors.map { |attribute, message| record.errors.full_message(attribute, message) }
        else
          [record.errors.full_message(field, errors)]
        end
      end
    end
  end
end
