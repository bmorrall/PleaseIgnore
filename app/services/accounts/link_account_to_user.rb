module Accounts
  # Creates a new account and links it with the current user
  class LinkAccountToUser
    include Concerns::Service

    class AccountDisabledError < AuthenticationError; end
    class AccountInvalidError < AuthenticationError; end
    class AccountLimitError < AuthenticationError; end
    class PreviouslyLinkedError < AuthenticationError; end

    attr_reader :user, :auth_hash, :provider
    attr_reader :account, :success

    def initialize(user, auth_hash, provider)
      @user = user
      @auth_hash = auth_hash
      @provider = provider
    end

    # Creates a new account and links it to the user
    #
    # @api public
    # @example LinkAccountToUser.call(auth_hash, provider)
    # @throws Accounts::AuthenticationError if the account cannot be linked to the user
    def call
      @account = Account.find_for_oauth(auth_hash, provider)
      if account.present?
        # Account has been found, ensure belongs to current user
        check_account_is_linked_to_user
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
      fail AccountDisabledError.new(:account_disabled, provider) if account.disabled?
      fail PreviouslyLinkedError.new(:previously_linked, provider) if account.user_id != user.id

      @success = :success_linked
    end

    # Links account the the current user
    def create_account_for_user
      # User already has linked to a provider account
      fail AccountLimitError.new(:account_limit, provider) if user.provider_account?(provider)
      @account = build_account
      fail AccountInvalidError.new(:account_invalid, provider) unless account.save

      @success = :success_linked
    end

    def build_account
      user.accounts.new_with_auth_hash(auth_hash, provider)
    end
  end
end
