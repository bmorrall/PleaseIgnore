module PaperTrail
  # Decorates a PaperTrail Version Object
  # Providers
  # - methods for display who, what and where of a change
  class VersionDecorator < Draper::Decorator
    delegate_all

    def comments
      h.content_tag :blockquote, object.comments if object.comments?
    end

    def created_at_ago
      h.local_time_ago object.created_at
    end

    def display_change_summary?
      object.changeset && object.changeset.any?
    end

    def change_summary
      return unless display_change_summary?
      DiffSummaryPresenter.display(h, object.changeset, object.item_type.safe_constantize)
    end

    def user_location
      if system_generated_entry?
        # System Generated Version
        object.whodunnit
      elsif object.ip.present? || object.user_agent.present?
        # Internet sourced version
        user_location_as_ip
      else
        h.content_tag :em, 'Unknown'
      end
    end

    def title
      event_type = object.event.titleize
      "#{event_type} #{object.item_type} ##{object.item_id}"
    end

    def whodunnit
      h.content_tag :span, class: 'whodunnit' do
        if object.whodunnit =~ /\A\d+\z/
          # Display as User action
          whodunnit_as_user
        elsif object.whodunnit
          # Display as System command
          whodunnit_as_command
        else
          # Display as Guest
          h.t('paper_trail.versions.whodunnit.guest')
        end
      end
    end

    def whodunnit_ago
      parts = [whodunnit, created_at_ago]

      if object.created_at > 1.day.ago
        parts.join(' ')
      else
        parts.join(' on ')
      end.html_safe
    end

    protected

    def system_generated_entry?
      object.whodunnit && object.whodunnit !~ /\A\d+\z/
    end

    def user_location_as_ip
      [
        h.user_agent_tag(object.user_agent),
        h.ip_address_tag(object.ip)
      ].reject(&:nil?).join(h.tag(:br)).html_safe
    end

    def whodunnit_as_command
      parts = object.whodunnit.split(': ', 2)
      command = parts.last

      if command =~ /rake/
        h.t('paper_trail.versions.whodunnit.rake')
      elsif command =~ /console/
        h.t('paper_trail.versions.whodunnit.console')
      else
        command.titleize
      end
    end

    def whodunnit_as_user
      user = User.with_deleted.find_by_id(object.whodunnit.to_i)
      if user
        "#{user.name} <#{user.email}>"
      else
        h.content_tag :em, "Removed User ##{object.whodunnit}"
      end
    end

    def date_is_today?
      h.date_is_today? object.created_at.to_date
    end
  end
end
