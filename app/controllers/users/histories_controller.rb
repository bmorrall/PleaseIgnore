module Users
  # Displays the Persional History of a User Account
  class HistoriesController < ApplicationController
    layout 'dashboard_backend'

    before_filter :authenticate_user!
    before_filter :authorize_read_versions

    # @api public
    # @example GET /users/history
    # @return void
    def show
      @versions = current_user.history
      @versions = @versions.reorder('created_at DESC')
    end

    protected

    def page_param
      params[:page] || 1
    end

    def authorize_read_versions
      authorize! :read, PaperTrail::Version
    end
  end
end
