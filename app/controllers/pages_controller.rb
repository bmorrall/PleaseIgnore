class PagesController < ApplicationController
  include HighVoltage::StaticPage
  include Concerns::ContentForLayout

  before_filter :set_page_metadata

  # Fix HighVoltage/pjax layout conflict
  # layout proc { |c| pjax_request? ? pjax_layout : HighVoltage.layout }

  protected

  def set_page_metadata
    params[:id].tap do |page|
      if %w(home privacy styles terms).include? page
        content_for_layout :page_title, t("pages.#{page}.page_title") unless page == 'home'
        content_for_layout :extra_body_classes, "#{page}-page"
      end
    end
  end

end
