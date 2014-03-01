class PagesController < ApplicationController
  include HighVoltage::StaticPage

  # Fix HighVoltage/pjax layout conflict
  # layout proc { |c| pjax_request? ? pjax_layout : HighVoltage.layout }

end
