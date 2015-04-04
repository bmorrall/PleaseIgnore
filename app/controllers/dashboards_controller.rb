# Dashboards Controller
# Displays a dashboard to users showing the status of their account and their pending tasks
class DashboardsController < ApplicationController
  layout 'dashboard'

  # User must be signed in to see Dashboard
  before_action :authenticate_user!

  # Don't check for permissions
  skip_authorization_check

  # GET /dashboard
  def show
    # show.html.erb
  end
end
