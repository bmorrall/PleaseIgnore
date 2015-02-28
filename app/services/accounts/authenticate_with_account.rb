module Accounts
  # Attempt to find existing account, or register a new account
  class AuthenticateWithAccount
    include Concerns::Service

    # Error while authenticating with an account
    class Error < ::StandardError
      attr_reader :provider, :provider_name
      def initialize(message_key, provider)
        @provider = provider
        @provider_name = Account.provider_name(provider)
        super I18n.t(message_key, scope: 'account.reasons.failure', kind: @provider_name)
      end
    end
    class AccountDisabledError < Error; end

    attr_reader :auth_hash, :provider
    attr_reader :account, :success
    delegate :user, to: :account

    def initialize(auth_hash, provider)
      @auth_hash = auth_hash
      @provider = provider
    end

    def call
      @account = Account.find_for_oauth(auth_hash, provider)
      if account.nil?
        # User needs to register an account
        @success = :success_registered
      elsif account.enabled?
        # User can be authenticated with account
        @success = :success_authenticated
      else
        # Prevent users from logging in with banned accounts
        fail AccountDisabledError.new(:account_disabled, provider)
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
