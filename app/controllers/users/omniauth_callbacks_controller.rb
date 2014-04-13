class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :verify_authenticity_token

  # Fake Developer Authentication
  def developer
    auth_hash = request.env["omniauth.auth"]
    if user_signed_in?
      link_account_with_current_user auth_hash, 'developer'
    else
      deny_sign_in_or_register_account auth_hash, 'developer'
    end
  end

  # Available OAuth Authentication
  %w(facebook github google_oauth2 twitter).each do |provider|
    define_method provider do
      auth_hash = request.env["omniauth.auth"]
      if user_signed_in?
        link_account_with_current_user auth_hash, provider
      else
        sign_in_or_register_account auth_hash, provider
      end
    end
  end

  protected

  def link_account_with_current_user(auth_hash, provider)
    account = Account.new_with_auth_hash(auth_hash, provider)
    account.user = current_user
    if account.save
      # Account has been linked to profile
      display_authenticated_flash_message provider
    else
      # Account has been linked to another profile
      display_failure_flash_message 'Someone has already linked to this account', provider
    end
    redirect_to edit_user_registration_path
  end

  def sign_in_or_register_account(auth_hash, provider)
    account = Account.find_for_oauth(auth_hash, provider)
    if account.present?
      sign_user_into_account account, provider
    else
      # Redirect to User Registration with auth hash
      redirect_user_to_registration_page auth_hash, provider
    end
  end

  def sign_user_into_account(account, provider)
    if account.enabled?
      # Sign in to profile owning linked account
      display_authenticated_flash_message provider
      sign_in_and_redirect account.user, :event => :authentication
    else
      display_failure_flash_message 'This account has been disabled', provider
      redirect_to new_user_session_path
    end
  end

  def deny_sign_in_or_register_account(auth_hash, provider)
    account = Account.find_for_oauth(auth_hash, provider)
    if account.present?
      # Deny Authentication from this Provider
      display_failure_flash_message 'Authentication is disabled from this Provider', provider
      redirect_to new_user_session_path
    else
      # Redirect to User Registration with auth hash
      redirect_user_to_registration_page auth_hash, provider
    end
  end

  def redirect_user_to_registration_page(auth_hash, provider)
    display_registration_flash_message provider
    save_auth_hash_to_session auth_hash, provider
    redirect_to new_user_registration_path
  end

  private
  
  def save_auth_hash_to_session(auth_hash, provider)
    # Save the auth hash without raw info
    session["devise.#{provider}_data"] = auth_hash.reject{ |key| key.to_sym == :raw_info }
  end

  # Successful authentication, but registration is required
  def display_registration_flash_message(provider)
    # TODO: Registration message
    display_authenticated_flash_message provider
  end

  # Successful authentication with the user being logged in
  def display_authenticated_flash_message(provider)
    set_flash_message(:notice, :success, :kind => Account::provider_name(provider)) if is_navigational_format?
  end

  def display_failure_flash_message(reason, provider)
    set_flash_message(:alert, :failure, :kind => Account::provider_name(provider), :reason => reason) if is_navigational_format?
  end

end
