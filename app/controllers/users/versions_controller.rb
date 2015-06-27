module Users
  # Renders the local history of a User, including changes made by the User
  class VersionsController < ApplicationController
    layout 'dashboard_backend'

    before_filter :authenticate_user!
    before_filter :authorize_inspect_history

    # @api public
    # @example GET /users/versions
    # @return void
    def index
      @versions = current_user.related_versions
      @versions = @versions.reorder('created_at DESC')
    end

    protected

    def authorize_inspect_history
      authorize! :inspect, PaperTrail::Version
    end
  end
end
