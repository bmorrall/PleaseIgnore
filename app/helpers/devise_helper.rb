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
end
