module Versions
  # Decorates a PaperTrail::Version Object that represents change to a Account Object
  # Providers
  # - methods for display who, what and where of a change
  class AccountDecorator < PaperTrail::VersionDecorator
    delegate_all

    def title
      event_type = object.event

      account = object.reify || Account.unscoped { object.item }

      I18n.t(
        event_type,
        item_id: object.item_id,
        account_uid: account.try(:account_uid) || '?',
        provider_name: account.try(:provider_name),
        scope: [:decorators, :versions, :title, :account]
      )
    end
  end
end
