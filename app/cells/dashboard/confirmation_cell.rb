require 'helpers/font_awesome_helper'

module Dashboard
  # Displays a Confirmation Form for Users to confirm their accounts
  class ConfirmationCell < ::ApplicationCell
    include ::FontAwesomeHelper
    helper_method :fa

    # Renders a confirm account message
    # @param user [User] User to receive confirmation message
    def display(user)
      @user = user
      render
    end
  end
end
