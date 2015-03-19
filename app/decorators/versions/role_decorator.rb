module Versions
  # Decorates a PaperTrail::Version Object that represents change to a Role Object
  # Providers
  # - methods for display who, what and where of a change
  class RoleDecorator < PaperTrail::VersionDecorator
    delegate_all

    def title
      event_type = object.event

      case object.item_owner_type
      when 'User'
        user_event_title(event_type)
      else
        resource_event_title(event_type)
      end
    end

    # Returns a capitalised version of the role name
    def role_name
      @role_name ||= object.meta[:role].try(:capitalize)
    end

    protected

    # Returns the title for a role that has been granted to a resource for a user
    def resource_event_title(event_type)
      user = User.with_deleted.find_by_id(object.meta[:user_id])

      I18n.t(
        event_type,
        role: role_name,
        user: user.try(:name),
        scope: [:decorators, :versions, :title, :role]
      )
    end

    # Returns the title for a role that has been granted to a user
    def user_event_title(event_type)
      event_type = "user_#{event_type}"

      I18n.t(
        event_type,
        role: role_name,
        scope: [:decorators, :versions, :title, :role]
      )
    end
  end
end
