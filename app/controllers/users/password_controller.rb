module Users
  # Provides a single page for viewing a users password
  class PasswordController < ApplicationController
    layout 'dashboard_backend'

    before_action :authenticate_user!
    skip_authorization_check # Disable CanCan

    # Displays the Change/Add Password screen
    #
    # @api public
    # @example GET /users/password
    # @return void
    def index
      # index.html.erb
    end
  end
end
