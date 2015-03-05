# Macros for testing with PaperTrail
module PaperTrailMacros
  # Enables PaperTrail versions for content within a block
  def with_versioning
    was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
    end
  end
end

RSpec.configure do |config|
  config.include PaperTrailMacros, type: :model
end
