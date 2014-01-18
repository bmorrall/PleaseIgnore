# Pages Controller
# Uses HighVoltage to render static pages.
#
# - Adds metadata for the application layout
# - Pages are cached by HighVoltage
class PagesController < ApplicationController
  include HighVoltage::StaticPage
  include Concerns::ContentForLayout

  FRONTEND_PAGES = %w{home about styles}

  skip_authorization_check # Pages are available for all
  skip_before_action :verify_authenticity_token # No actions are here

  before_action :add_cache_control_headers
  before_action :set_page_metadata

  # Cache the show action
  caches_action :show, layout: true, expires_in: 1.hour

  # Change the layout based on contents
  layout :layout_for_page

  protected

  # Adds Metadata based on the current page
  def set_page_metadata
    params[:id].tap do |page|
      if %w(home about privacy styles terms).include? page
        page_title t("pages.#{page}.page_title") unless page == 'home'
        page_author t("pages.#{page}.page_author", default: '')
        page_description t("pages.#{page}.page_description", default: '')
        extra_body_classes "#{page}-page"
      end
    end
  end

  def layout_for_page
    if FRONTEND_PAGES.include? params[:id]
      'frontend_static'
    else
      'backend_static'
    end
  end
end
