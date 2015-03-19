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
  # Disable PaperTrail during specs
  config.before(:each) do
    PaperTrail.enabled = false
  end
  config.before(:each, type: :feature) do
    PaperTrail.enabled = true
  end

  # Allow PaperTrail to be selectively enabled
  config.include PaperTrailMacros, paper_trail: true
end
