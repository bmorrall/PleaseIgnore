# Macros for testing with PaperTrail
module PaperTrailMacros
  # Enables PaperTrail versions for content within a block
  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_controller = PaperTrail.enabled_for_controller?
    PaperTrail.enabled = true
    PaperTrail.enabled_for_controller = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.enabled_for_controller = was_enabled_for_controller
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    PaperTrail.whodunnit = 'rspec'
    PaperTrail.enabled = false
    PaperTrail.enabled_for_controller = false
  end
  config.around(type: :feature) do |example|
    with_versioning do
      example.run
    end
  end

  # Allow PaperTrail to be selectively enabled
  config.include PaperTrailMacros, paper_trail: true
  config.include PaperTrailMacros, type: :feature
  config.include PaperTrailMacros, type: :request
end
