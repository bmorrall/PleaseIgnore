require 'core_extensions/paper_trail/version_item_owner'

# Add Extensions onto the Version Model
PaperTrail::Version.include CoreExtensions::PaperTrail::VersionItemOwner

module PaperTrail
  # Additional features for PaperTrail::Version
  class Version < ActiveRecord::Base
    # Add meta attributes onto version table
    store :meta, accessors: [:ip, :user_agent, :comments], coder: JSON
  end
end

# Remove Rails 4.2 Deprecation Warnings
current_behavior = ActiveSupport::Deprecation.behavior
ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
  return if message =~ /`serialized_attributes` is deprecated without replacement/ &&
            callstack.any? { |m| m =~ /paper_trail/ }
  Array.wrap(current_behavior).each { |behavior| behavior.call(message, callstack) }
end
