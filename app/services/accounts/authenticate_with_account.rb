module Accounts
  # Attempt to find existing account, or register a new account
  class AuthenticateWithAccount
    include Concerns::Service

    class AccountDisabledError < AuthenticationError; end

    attr_reader :auth_hash, :provider
    attr_reader :account, :success
    delegate :user, to: :account

    def initialize(auth_hash, provider)
      @auth_hash = auth_hash
      @provider = provider
    end

    # Sets #success to true, if the account exists or has not been connected yet.
    #
    # @api public
    # @example AuthenticateWithAccount.call(auth_hash, provider)
    # @throws Accounts::AuthenticationError if the account has been disabled
    def call
      @account = Account.find_for_oauth(auth_hash, provider)
      if account.nil?
        # User needs to register an account
        @success = :success_registered
      else
        # Prevent users from logging in with banned accounts
        raise AccountDisabledError.new(:account_disabled, provider) unless account.enabled?

        # User can be authenticated with account
        @success = :success_authenticated
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

    def user_persisted?
      !!account.try(:user).try(:persisted?)
    end
  end
end
