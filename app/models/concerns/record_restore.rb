module Concerns # :nodoc:
  # Ensures a PaperTrail::Version is created on restore
  #
  # Must be included _AFTER_ has_paper_trail call
  module RecordRestore
    extend ActiveSupport::Concern

    protected

    # [paper_trail] tricks record_update into creating a 'restore' event
    def record_restore
      self.paper_trail_event = 'restore'
      record_update.save! # NOTE: Future versions of paper_trail call create
      clear_version_instance!
      self.paper_trail_event = nil
    end

    private

    # [paper_trail] ensure changed_notably is true for a restore instance
    def changed_notably?
      super || paper_trail_event == 'restore'
    end
  end
end
