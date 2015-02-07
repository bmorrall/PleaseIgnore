# Set whodunnint for non-ActionController changes
if defined?(::Rails::Console)
  # Keep track of console users
  PaperTrail.whodunnit = "#{`whoami`.strip}: console"
elsif File.basename($PROGRAM_NAME) == 'rake'
  # Keep track of rake tasks
  PaperTrail.whodunnit = "#{`whoami`.strip}: rake #{ARGV.join ' '}"
end

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
