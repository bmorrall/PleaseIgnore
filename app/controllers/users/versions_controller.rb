module Users
  # Renders the local history of a User, including changes made by the User
  class VersionsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource class: 'PaperTrail::Version',
                                through: :current_user,
                                through_association: :related_versions

    # GET /users/versions
    def index
      @versions = @versions.reorder('created_at DESC')
    end
  end
end
