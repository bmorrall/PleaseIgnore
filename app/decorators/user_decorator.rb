class UserDecorator < Draper::Decorator
  delegate_all

  def display_name
    h.content_tag :span, object.name || object.id, class: 'user-name'
  end

  def profile_image
    image_source = object.profile_picture(32)
    h.image_tag image_source, class: 'profile-image' if image_source
  end
end
