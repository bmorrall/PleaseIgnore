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
    skip_before_filter :verify_authenticity_token

    # Ensure User can create accounts
    before_filter do
      authorize! :create, Account
    end

    # Fake Developer Authentication

    # GET /users/developer/callback
    def developer
      if user_signed_in?
        link_account_with_current_user 'developer'
      else
        deny_sign_in_or_register_account 'developer'
      end
    end

    # Enabled OAuth Authentication

    %w(facebook github google_oauth2 twitter).each do |provider|
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
    def link_account_with_current_user(provider)
      account = Account.new_with_auth_hash(auth_hash, provider)
      account.user = current_user
      if account.save
        # Account has been linked to profile
        display_linked_success_flash_message provider
      else
        # Account has been linked to another profile
        display_failure_flash_message 'previously_linked', provider
      end
      redirect_to edit_user_registration_path
    end

    # Attempt to find existing account, or register a new account
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

    # Attempt to find account or register, but do not allow user to sign in
    def deny_sign_in_or_register_account(provider)
      account = Account.find_for_oauth(auth_hash, provider)
      if account.present?
        # Deny Authentication from this Provider
        display_failure_flash_message 'provider_disabled', provider
        redirect_to new_user_session_path
      else
        # Redirect to User Registration with auth hash
        redirect_user_to_registration_page provider
      end
    end

    private

    def redirect_user_to_registration_page(provider)
      display_registration_success_flash_message provider
      save_auth_hash_to_session provider
      redirect_to new_user_registration_path
    end

    # Store the auth_hash for registration
    def save_auth_hash_to_session(provider)
      # Save the auth hash without raw info
      session["devise.#{provider}_data"] = auth_hash.reject { |key| key.to_sym == :raw_info }
    end

    # Successful authentication, but registration is required
    def display_registration_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_registered, kind: provider_name)
    end

    # Successfully logged in user from account
    def display_authentication_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_authenticated, kind: provider_name)
    end

    # Successfully added account to existing user
    def display_linked_success_flash_message(provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, :success_linked, kind: provider_name)
    end

    # Unable to sign in user due to `reason`
    def display_failure_flash_message(reason, provider)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      reason = t(reason, scope: 'account.reasons.failure')
      set_flash_message(:alert, :failure, kind: provider_name, reason: reason)
    end
  end
end
