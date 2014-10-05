# Classes for Managing the Current User Session
module Users
  # Users OmniAuth Callbacks Controller
  # Allows for OmniAuth accounts to added to User accounts
  #
  # With a logged in User:
  # - Attempts to add Account to current_user
  #
  # With a guest:
  # - If account if previously connected, attempts to sign user in
  # - Otherwise, Redirects to registration, and links account on successful registration.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Don't check CSRF for callbacks
    skip_before_action :verify_authenticity_token

    # Ensure User can create accounts
    before_action do
      authorize! :create, Account
    end

    # OAuth Authentication

    Account::PROVIDERS.each do |provider|
      # GET /users/#[provider]/callback
      define_method provider do
        if user_signed_in?
          link_account_with_current_user provider
        else
          sign_in_or_register_account provider
        end
      end
    end

    protected

    # Auth Hash provided by Omniauth
    def auth_hash
      @auth_hash ||= request.env['omniauth.auth']
    end

    # Create a new account and link it with the current user
    #
    # @param provider [String] name of the provider responsible for Account
    def link_account_with_current_user(provider)
      account = Account.find_for_oauth(auth_hash, provider)
      if account.present?
        display_account_linked_message(provider, account)
      elsif current_user.provider_account? provider
        # User already has account linked to profile
        display_failure_flash_message 'account_limit', provider
      else
        link_account_to_current_user(provider)
      end
      redirect_to edit_user_registration_path
    end

    # Attempt to find existing account, or register a new account
    #
    # @param provider [String] name of the provider responsible for Account
    def sign_in_or_register_account(provider)
      account = Account.find_for_oauth(auth_hash, provider)
      if account.present?
        sign_in_with_exiting_account account
      else
        # Redirect to User Registration with auth hash
        redirect_user_to_registration_page provider
      end
    end

    # Attempt to sign in with account if it is enabled
    # @param account [Account] Existing Account used to sign user in
    def sign_in_with_exiting_account(account)
      provider = account.provider
      if account.enabled?
        # Sign in to profile owning linked account
        display_authentication_success_flash_message provider
        sign_in_and_redirect account.user, event: :authentication
      else
        # Prevent users from logging in with banned accounts
        display_failure_flash_message 'account_disabled', provider
        redirect_to new_user_session_path
      end
    end

    private

    # Links account the the current user
    #
    # @param provider [String] provider auth has belongs to
    def link_account_to_current_user(provider)
      account = current_user.accounts.new_with_auth_hash(auth_hash, provider)
      if account.save
        # Account has been linked to profile
        display_linked_success_flash_message provider
      else
        # Account is not valid and cannot be saved
        display_failure_flash_message 'account_invalid', provider
      end
    end

    # Redirects user to the new account registration page.
    # Saves the auth hash for the provider to the Session.
    #
    # @param provider [String] name of the provider to save attributes for
    def redirect_user_to_registration_page(provider)
      display_registration_success_flash_message provider
      save_auth_hash_to_session provider
      redirect_to new_user_registration_path
    end

    # Store the auth_hash for registration
    # @param provider [String] name of the provider to store session for
    def save_auth_hash_to_session(provider)
      # Save the auth hash without raw info
      session["devise.#{provider}_data"] = auth_hash.reject { |key| key.to_sym == :raw_info }
    end

    # Account has previously been linked, display success or alert
    def display_account_linked_message(provider, account)
      if account.user_id == current_user.id
        display_linked_success_flash_message provider
      else
        display_failure_flash_message 'previously_linked', provider
      end
    end

    # Successful authentication, but registration is required
    # @param provider [String] changes variant of alert message
    def display_registration_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_registered, kind: provider_name)
    end

    # Successfully logged in user from account
    # @param provider [String] changes variant of alert message
    def display_authentication_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_authenticated, kind: provider_name)
    end

    # Successfully added account to existing user
    # @param provider [String] changes variant of alert message
    def display_linked_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_linked, kind: provider_name)
    end

    # Unable to sign in user due to `reason`
    # @param provider [String] changes variant of alert message
    def display_failure_flash_message(reason, provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      reason = t(reason, scope: 'account.reasons.failure', kind: provider_name)
      set_flash_message(:alert, :failure, kind: provider_name, reason: reason)
    end
  end
end
