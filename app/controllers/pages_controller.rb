# Pages Controller
# Uses HighVoltage to render static pages.
#
# - Adds metadata for the application layout
# - Pages are cached by HighVoltage
class PagesController < ApplicationController
  include HighVoltage::StaticPage
  include Concerns::ContentForLayout

  skip_authorization_check # Pages are available for all

  before_action :set_page_metadata

  # Cache the show action
  caches_action :show, layout: false

  # Fix HighVoltage/pjax layout conflict
  # layout proc { |c| pjax_request? ? pjax_layout : HighVoltage.layout }

  protected

  # Adds Metadata based on the current page
  def set_page_metadata
    params[:id].tap do |page|
      if %w(home privacy styles terms).include? page
        page_title t("pages.#{page}.page_title") unless page == 'home'
        page_author t("pages.#{page}.page_author", default: '')
        page_description t("pages.#{page}.page_description", default: '')
        extra_body_classes "#{page}-page"
      end
    end
  end
end
