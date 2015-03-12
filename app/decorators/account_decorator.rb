# Decorates Accounts
# Provides:
#  - Basic Account display methods
#  - Helpers for displaying a alert banner
class AccountDecorator < Draper::Decorator
  delegate_all

  # Alert Display Helpers

  # Returns a url to an icon representing the account type
  def account_icon
    h.provider_icon object.provider
  end

  # Alert Banner Helpers

  # Returns a button for removing a account
  def summary_delete_button
    if object.persisted?
      destroy_account_button if h.can?(:destroy, object)
    else
      cancel_registration_button
    end
  end

  # Displays a summary link / label of the account
  def summary_field
    if object.website?
      h.external_link object.website, class: 'form-control' do
        object.account_uid
      end
    else
      h.link_to '#', class: 'form-control', disabled: true do
        object.account_uid
      end
    end
  end

  # Renders the account image as an addon for summary_field
  def summary_image
    account_image = object.image
    return unless account_image

    h.content_tag :span, class: 'input-group-addon account-image' do
      h.image_tag account_image, size: '32x32'
    end
  end

  protected

  # Renders a button for cancelling registration (hence removing a session account)
  def cancel_registration_button
    # Display link to cancel registration
    h.system_link(
      '&times;'.html_safe,
      h.cancel_user_registration_path,
      method: 'get',
      class: 'input-group-addon cancel-signup',
      data: {
        confirm: I18n.t('decorators.account.prompts.cancel_registration')
      }
    )
  end

  # Renders a button for destroying a account
  def destroy_account_button
    # Display link to remove account
    provider_class = h.provider_class(object.provider)
    h.system_link(
      '&times;'.html_safe,
      h.users_account_path(object),
      method: 'delete',
      class: "input-group-addon unlink-account unlink-#{provider_class}",
      data: {
        confirm: I18n.t('decorators.account.prompts.unlink_account', object.provider_name)
      }
    )
  end
end
