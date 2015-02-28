module Accounts
  # Creates a new account and links it with the current user
  class LinkAccountToUser
    include Concerns::Service

    # Error while linking account to a user
    class Error < ::StandardError
      attr_reader :provider, :provider_name
      def initialize(message_key, provider)
        @provider = provider
        @provider_name = Account.provider_name(provider)
        super I18n.t(message_key, scope: 'account.reasons.failure', kind: @provider_name)
      end
    end
    class AccountDisabledError < Error; end
    class AccountInvalidError < Error; end
    class AccountLimitError < Error; end
    class PreviouslyLinkedError < Error; end

    attr_reader :user, :auth_hash, :provider
    attr_reader :account, :success

    def initialize(user, auth_hash, provider)
      @user = user
      @auth_hash = auth_hash
      @provider = provider
    end

    def call
      @account = Account.find_for_oauth(auth_hash, provider)
      if account.present?
        # Account has been found, ensure belongs to current user
        check_account_is_linked_to_user
      elsif user.provider_account? provider
        # User already has linked to a provider account
        fail AccountLimitError.new(:account_limit, provider)
      else
        # Need to create account for current user
        create_account_for_user
      end
    end

    def success_message
      @success_message ||=
        I18n.t(
          @success,
          scope: 'devise.omniauth_callbacks',
          kind: Account.provider_name(provider)
        )
    end

    protected

    # Account has previously been linked, display success or alert
    def check_account_is_linked_to_user
      if account.user_id.blank?
        # User belongs to another user
        fail AccountDisabledError.new(:account_disabled, provider)
      elsif account.user_id == user.id
        # Account has already been linked to this user
        @success = :success_linked
      else
        # User belongs to another user
        fail PreviouslyLinkedError.new(:previously_linked, provider)
      end
    end

    # Links account the the current user
    def create_account_for_user
      @account = user.accounts.new_with_auth_hash(auth_hash, provider)
      if account.save
        # Account has been linked to profile
        @success = :success_linked
      else
        # Account is not valid and cannot be saved
        fail AccountInvalidError.new(:account_invalid, provider)
      end
    end
  end
end
