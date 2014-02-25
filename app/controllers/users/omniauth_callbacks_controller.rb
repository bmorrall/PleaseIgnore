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
      set_flash_message(:notice, :success, :kind => Account::provider_name(provider)) if is_navigational_format?
    else
      # Account has been linked to another profile
      set_flash_message(:alert, :failure, :kind => Account::provider_name(provider), :reason => 'Someone has already linked to this account') if is_navigational_format?
    end
    redirect_to edit_user_registration_path
  end

  def sign_in_or_register_account(auth_hash, provider)
    account = Account.find_for_oauth(auth_hash, provider)
    if account.present? 
      if account.enabled?
        # Sign in to profile owning linked account
        set_flash_message(:notice, :success, :kind => Account::provider_name(provider)) if is_navigational_format?
        sign_in_and_redirect account.user, :event => :authentication
      else
        set_flash_message(:alert, :failure, :kind => Account::provider_name(provider), :reason => 'This account has been disabled') if is_navigational_format?
        redirect_to new_user_session_path
      end
    else
      # Redirect to User Registration with auth hash
      set_flash_message(:notice, :success, :kind => Account::provider_name(provider)) if is_navigational_format?
      session["devise.#{provider}_data"] = auth_hash.reject{ |k| k.to_sym == :raw_info }
      redirect_to new_user_registration_path
    end
  end

  def deny_sign_in_or_register_account(auth_hash, provider)
    account = Account.find_for_oauth(auth_hash, provider)
    if account.present? 
      # Deny Authentication from this Provider
      set_flash_message(:alert, :failure, :kind => Account::provider_name(provider), :reason => 'Authentication is disabled from this Provider') if is_navigational_format?
      redirect_to new_user_session_path
    else
      # Redirect to User Registration with auth hash
      set_flash_message(:notice, :success, :kind => Account::provider_name(provider)) if is_navigational_format?
      session["devise.#{provider}_data"] = auth_hash.reject{ |k| k.to_sym == :raw_info }
      redirect_to new_user_registration_path
    end
  end

end
