module Dashboard
  # An Empty Cell used as a fallback for Dashboards with no contents
  class EmptyCell < ::ApplicationCell
    helper FontAwesomeHelper

    # Renders an empty dashboard message
    def display(*)
      render
    end
  end
end
