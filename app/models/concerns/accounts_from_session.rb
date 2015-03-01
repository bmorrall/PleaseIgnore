module Concerns # :nodoc:
  # Stores Accounts from Session Variables and saves them after_create
  #
  # Must be included _AFTER_ has_paper_trail call
  module AccountsFromSession
    extend ActiveSupport::Concern

    included do
      # Save built accounts that have been imported from a session
      after_create :save_new_session_accounts

      # [Devise] Returns a new user from Session data.
      # Saves stored accounts to #new_session_accounts if auth hash is found in session.
      #
      # @param _params [Hash] params from Controller request
      # @param session [Hash] stored Guest session data
      # @return [User] new User object with Accounts loaded from `session`
      def self.new_with_session(_params, session)
        super.tap do |user|
          user.send :add_accounts_from_session, session
        end
      end
    end

    # @return [Array] Array of Accounts that will be saved on create
    def new_session_accounts
      @new_session_accounts ||= []
    end

    protected

    # Collects auth hashes from all stored providers and adds them to the new_session_accounts
    # temporary list.
    def save_new_session_accounts
      new_session_accounts.each do |account|
        account.user = self
        next if account.save

        # Add errors to model and raise exception
        logger.error "Unable to save Account: #{account.provider}: #{account.uid}"
        error_message = "Unable to add your #{Account.provider_name(account.provider)} account"
        errors.add :base, error_message
        fail ActiveRecord::RecordInvalid, account
      end
    end

    # Collections auth hashes from all stored providers and adds them to
    # the `new_session_accounts` temporary list
    #
    # @param session [Hash] Guest session containg provider auth hashes
    def add_accounts_from_session(session)
      Account::PROVIDERS.each do |provider|
        provider_key = "devise.#{provider}_data"
        next unless (data = session[provider_key])

        # Add account to new session accounts
        account = Account.new_with_auth_hash(data, provider)
        update_defaults_from_account account
        new_session_accounts << account
      end
    end
  end
end
