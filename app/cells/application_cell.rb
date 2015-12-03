# Base Class for using Cells.
#
# Adds commonly used helpers and methods to cells.
class ApplicationCell < Cell::ViewModel
  # Include all the application helper methods
  include ApplicationHelper
  include FontAwesomeHelper

  # You need to include controller methods you where using from Rails explicitly.
  include AbstractController::Helpers
  include AbstractController::Translation
  # Look at https://github.com/rails/rails/tree/4-2-3/actionpack/lib/abstract_controller
  # if you need more.

  # If you want to access controller methods from your cell, you can hook that up like this
  delegate :current_user, :controller_name, :flash, to: :parent_controller
  helper_method :current_user
  helper_method :controller_name
  helper_method :flash

  # Cells 4 no longer uses action_name.
  # This workaround sets it whenever a state is called.
  # @api private
  attr_accessor :action_name

  # Defaults to displaying show
  # @param state method to call when rendering cell
  def call(state = :show, *args)
    @action_name = state
    super
  end
end
