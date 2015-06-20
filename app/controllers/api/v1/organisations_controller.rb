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

      # Returns a JSON representation of all Organisations the current user belongs to
      #
      # @api public
      # @example GET /api/v1/organisations
      # @return void
      def index
        # index.json.jbuilder
      end

      # Returns a JSON representation of an Organisation
      #
      # @api public
      # @example GET /api/v1/organisation/:id
      # @raise [CanCan::AccessDenied] if the current user does not belong to the Organisation
      # @return void
      def show
        # show.json.jbuilder
      end

      private

      # Loads all Organisations the current user belongs to and assigns them to @organisations
      # @api private
      # @return void
      def load_organisation
        @organisations = current_user.organisations
      end
    end
  end
end
