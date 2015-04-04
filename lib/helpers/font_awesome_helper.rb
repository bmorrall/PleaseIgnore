# Helpers for using FontAwesome Icons (http://fortawesome.github.io/Font-Awesome/)
module FontAwesomeHelper
  # Displays a Font Awesome icon in a non semantic tag.
  #
  # @param icon_name [String] icon name without the fa- previx
  # @see http://fortawesome.github.io/Font-Awesome/icons/
  def fa(icon_name)
    content_tag :i, nil, class: "fa fa-#{icon_name}"
  end
end
