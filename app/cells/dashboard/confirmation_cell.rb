require 'helpers/font_awesome_helper'

module Dashboard
  # Displays a Confirmation Form for Users to confirm their accounts
  class ConfirmationCell < Cell::Rails
    include ::FontAwesomeHelper
    helper_method :fa

    def display(user)
      @user = user
      render
    end
  end
end
