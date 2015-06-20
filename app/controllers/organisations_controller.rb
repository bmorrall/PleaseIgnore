# Allows Users to Create and Update Organisations
class OrganisationsController < ApplicationController
  include Concerns::BetterTurboboostErrors

  before_action :authenticate_user!
  before_action :load_organisation, only: [:index]
  load_and_authorize_resource through: :current_user, find_by: :permalink

  respond_to :html

  layout :organisation_layout

  # @api public
  # @example GET /organisations/1
  # @return void
  def show
  end

  # @api public
  # @example GET /organisations/1/edit
  # @return void
  def edit
  end

  # @api public
  # @example PATCH/PUT /organisations/1
  # @return void
  def update
    @organisation.update(organisation_params)
    respond_with(@organisation)
  end

  private

  # Assigns all Organisations the current user belongs to, to @organisations
  #
  # @api private
  # @return void
  def load_organisation
    @organisations = current_user.organisations
  end

  # @api private
  # @return [String] backend layout for settings, otherwise the frontend dashboard
  def organisation_layout
    %w(edit update destroy).include?(params[:action]) ? 'dashboard_backend' : 'dashboard'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  #
  # @api private
  # @return [Hash] Params safe for updating a {Organisation}
  def organisation_params
    organisation_params = [:name]
    params.require(:organisation).permit(organisation_params)
  end
end
