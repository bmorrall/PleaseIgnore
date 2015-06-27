# Helpers to simplify devise views
module DeviseHelper
  # Labels for terms and conditions
  def terms_and_conditions_label
    terms_of_service_link = external_link t('.labels.terms_of_service'), page_path('terms')
    privacy_policy_link = external_link t('.labels.privacy_policy'), page_path('privacy')
    content_tag :span do
      t(
        '.labels.terms_and_conditions',
        terms_of_service: terms_of_service_link,
        privacy_policy: privacy_policy_link
      ).html_safe
    end
  end

  # Input tag for displaying a profile image
  def avatar_image_input_tag(profile_image)
    return if profile_image.blank?

    content_tag :div, class: 'form-group' do
      [
        avatar_image_label_tag,
        avatar_image_input_field(profile_image)
      ].join.html_safe
    end
  end

  private

  # Displays a label for the avatar image
  def avatar_image_label_tag
    content_tag(:label, User.human_attribute_name(:avatar), class: 'control-label col-sm-3')
  end

  # Displays an input field with a link to gravatar.com
  #
  # @param [String] profile_image path to profile image
  def avatar_image_input_field(profile_image)
    profile_image_tag = image_tag(profile_image, size: '32x32')

    content_tag(:div, class: 'col-sm-9 col-md-7') do
      content_tag(:div, class: 'input-group') do
        [
          content_tag(:span, profile_image_tag, class: 'input-group-addon account-image'),
          external_link(t('.labels.avatar_hint'), 'https://gravatar.com', class: 'form-control')
        ].join.html_safe
      end
    end
  end
end
