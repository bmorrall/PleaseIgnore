# Allows Users to Create and Update Organisations
class OrganisationsController < ApplicationController
  include Concerns::BetterTurboboostErrors

  before_action :authenticate_user!
  before_action :load_organisation, only: [:index]
  load_and_authorize_resource through: :current_user, find_by: :permalink

  respond_to :html

  layout :organisation_layout

  # GET /organisations/1
  # GET /organisations/1.json
  def show
  end

  # GET /organisations/1/edit
  def edit
  end

  # PATCH/PUT /organisations/1
  # PATCH/PUT /organisations/1.json
  def update
    @organisation.update(organisation_params)
    respond_with(@organisation)
  end

  private

  def load_organisation
    @organisations = current_user.organisations
  end

  def organisation_layout
    %w(edit update destroy).include?(params[:action]) ? 'dashboard_backend' : 'dashboard'
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def organisation_params
    organisation_params = [:name]
    params.require(:organisation).permit(organisation_params)
  end
end
