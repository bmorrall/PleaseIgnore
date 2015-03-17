# Decorates a User Objects
# Providers
# - helper for displaying name
# - helper for displaying profile images
class UserDecorator < Draper::Decorator
  delegate_all

  # Displays name wrapped in standard `user-name` class
  def display_name
    h.content_tag :span, object.name || object.id, class: 'user-name'
  end

  # Displays default sized profile image (32px)
  def profile_image
    image_source = Rails.cache.fetch([object, :profile_image]) do
      object.profile_picture(32)
    end
    h.image_tag image_source, class: 'profile-image' if image_source
  end
end
