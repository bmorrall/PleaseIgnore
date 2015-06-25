module Accounts
  # Error while authenticating with an account
  class AuthenticationError < ::StandardError
    attr_reader :provider
    attr_reader :provider_name

    def initialize(message_key, provider)
      @provider = provider
      @provider_name = Account.provider_name(provider)
      super I18n.t(message_key, scope: 'account.reasons.failure', kind: @provider_name)
    end
  end
end
