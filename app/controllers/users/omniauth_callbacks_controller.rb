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

    rescue_from Accounts::LinkAccountToUser::Error, with: :handle_link_account_error
    rescue_from Accounts::AuthenticateWithAccount::Error, with: :handle_account_authentication_error

    # OAuth Authentication

    Account::PROVIDERS.each do |provider|
      # GET /users/#[provider]/callback
      # @!method $1()
      define_method provider do
        if user_signed_in?
          # Attempt to link account to current user
          account = Accounts::LinkAccountToUser.call(current_user, auth_hash, provider)

          redirect_to edit_user_registration_path, notice: account.success_message
        else
          # Attempt to authenticate with account
          account = Accounts::AuthenticateWithAccount.call(auth_hash, provider)

          if account.user_persisted?
            flash[:notice] = account.success_message
            sign_in_and_redirect account.user, event: :authentication
          else
            # Save auth hash for registration
            save_auth_hash_to_session(provider)
            redirect_to new_user_registration_path, notice: account.success_message
          end
        end
      end
    end

    private

    # Auth Hash provided by Omniauth
    # @api private
    # @return [Hash] Omniauth Hash with Account Credentials
    def auth_hash
      @auth_hash ||= request.env['omniauth.auth']
    end

    # Displays success flash message
    # @param provider [String] changes variant of notice flash message
    # @param message [String] message to display to the user
    # @api private
    # @return void
    def display_success_flash_message(provider, message)
      return unless is_navigational_format?

      provider_name = Account.provider_name(provider)
      set_flash_message(:notice, message, kind: provider_name)
    end

    # Displays a failure message when linking to an account
    # @api private
    # @return void
    def handle_link_account_error(account_error)
      return unless is_navigational_format?

      reason = account_error.message
      provider_name = account_error.provider_name

      set_flash_message(:alert, :failure, kind: provider_name, reason: reason)
      redirect_to edit_user_registration_path
    end

    # Displays a failure message when authenticating with an account
    # and redirects the user to the login form
    # @api private
    # @return void
    def handle_account_authentication_error(account_error)
      return unless is_navigational_format?

      reason = account_error.message
      provider_name = account_error.provider_name

      set_flash_message(:alert, :failure, kind: provider_name, reason: reason)
      redirect_to new_user_session_path
    end

    # Store the auth_hash for registration
    # @param provider [String] name of the provider to store session for
    # @api private
    # @return void
    def save_auth_hash_to_session(provider)
      # Save the auth hash without raw info
      session["devise.#{provider}_data"] = auth_hash.reject { |key| key.to_sym == :raw_info }
    end
  end
end
