require 'core_extensions/paper_trail/version_item_owner'
require 'core_extensions/paper_trail/version_meta_store'

# Disable track_associations and allow assets to be compiled
PaperTrail.config.track_associations = false

# Remove Rails 4.2 Deprecation Warnings
current_behavior = ActiveSupport::Deprecation.behavior
ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
  return if message =~ /`serialized_attributes` is deprecated without replacement/ &&
            callstack.any? { |m| m =~ /paper_trail/ }
  Array.wrap(current_behavior).each { |behavior| behavior.call(message, callstack) }
end
