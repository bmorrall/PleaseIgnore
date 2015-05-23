module Api
  module V1
    # Renders Organisation belonging to the current user
    class OrganisationsController < Api::V1::ApplicationController
      before_action :authenticate_user!
      before_action :load_organisation, only: [:index]
      load_and_authorize_resource :organisation,
                                  through: :current_user,
                                  parent: false,
                                  find_by: :permalink

      # GET /api/v1/organisations
      def index
        # index.json.jbuilder
      end

      # GET /api/v1/organisation/:id
      def show
        # show.json.jbuilder
      end

      private

      def load_organisation
        @organisations = current_user.organisations
      end
    end
  end
end
