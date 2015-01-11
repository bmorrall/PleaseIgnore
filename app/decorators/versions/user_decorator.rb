module Versions
  # Decorates a PaperTrail::Version Object that represents change to a User Object
  # Providers
  # - methods for display who, what and where of a change
  class UserDecorator < PaperTrail::VersionDecorator
    delegate_all

    def title
      if h.current_user.id == item_id
        # User has changed own account (Profile)
        title_for_profile
      else
        # User has changed another account
        title_for_user
      end
    end

    protected

    def title_for_profile
      I18n.t(
        object.event,
        item_id: object.item_id,
        scope: [:decorators, :versions, :title, :profile],
        default: title_for_user
      )
    end

    def title_for_user
      I18n.t(
        object.event,
        item_id: object.item_id,
        scope: [:decorators, :versions, :title, :user]
      )
    end
  end
end
