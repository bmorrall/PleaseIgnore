module Concerns
  module Users
    # Adds require methods for using Accounts to authenticate with devise
    module DeviseAccountAuthentication
      extend ActiveSupport::Concern

      included do
        devise(
          :omniauthable,
          omniauth_providers: [
            :developer,
            :facebook,
            :twitter,
            :github,
            :google_oauth2
          ]
        )

        # Associations

        has_many :accounts,
                 -> { order 'position ASC, accounts.type ASC' },
                 foreign_key: :user_id,
                 dependent: :destroy

        # Callbacks

        # Save built accounts that have been imported from a session
        after_create :save_new_session_accounts

        # Devise Overrides

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

        # [Devise] Allows valid_password to accept a nil current_password value
        def update_with_password(params, *options)
          @allow_empty_password = encrypted_password.blank?
          super
        ensure
          @allow_empty_password = false
        end

        # Verifies whether an password (ie from sign in) is the user password.
        def valid_password?(password)
          # User is adding a password
          return allow_empty_password? if password.nil? && encrypted_password.blank?
          super # Fallback to standard logic
        end
      end

      # Returns true if the user has at least one Account with `provider`
      #
      # @param provider [String] name of provider
      # @return [Boolean] true if the account has a provider account
      def provider_account?(provider)
        account_type = Account.provider_account_class(provider).name
        accounts.where(type: account_type).any?
      end

      # Primary account of user
      def primary_account
        accounts.first
      end

      # Updates default properties from account
      #
      # @param account [Account] updated Account belonging to user
      def update_defaults_from_account(account)
        self.name = account.name if name.blank?
        self.email = account.email if email.blank?
      end

      # New Session Accounts

      # @return [Array] Array of Accounts that will be saved on create
      def new_session_accounts
        @new_session_accounts ||= []
      end

      # Devise Overrides

      # [Devise] Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        (!persisted? && new_session_accounts.empty?) ||
          !password.nil? ||
          !password_confirmation.nil?
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

      def allow_empty_password?
        !!@allow_empty_password
      end
    end
  end
end
