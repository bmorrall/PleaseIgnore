# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  provider         :string(255)      not null
#  uid              :string(255)      not null
#  name             :string(255)
#  nickname         :string(255)
#  image            :string(255)
#  website          :string(255)
#  oauth_token      :string(255)
#  oauth_secret     :string(255)
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#

class Account < ActiveRecord::Base
  PROVIDERS = %w(facebook twitter github google_oauth2 developer)

  # Associations

  belongs_to :user, touch: true
  acts_as_list scope: :user

  # Attributes

  attr_accessor :email

  # Class Methods

  # Finds a existing Account from an OmniAuth hash, and updates from latest details
  def self.find_for_oauth(auth_hash, force_provider = nil)
    provider = auth_hash.provider
    if force_provider && provider != force_provider
      # Provider from hash doesn't match expected values
      fail "Provider (#{provider}) doesn't match expected value: #{force_provider}"
    end

    find_by_provider_and_uid(provider, auth_hash.uid).tap do |account|
      account.update_and_save_from_auth_hash(auth_hash) if account
    end
  end

  # Creates a New Account based off OmniAuth Hash
  def self.new_with_auth_hash(data, force_provider = nil)
    provider = data['provider']
    if force_provider && provider != force_provider
      # Provider from hash doesn't match expected values
      fail "Provider (#{provider}) doesn't match expected value: #{force_provider}"
    end

    Account.new(
      provider: provider,
      uid: data['uid']
    ).update_from_auth_hash(data)
  end

  # List of available OmniAuth Providers
  def self.omniauth_providers
    Devise.omniauth_configs.keys.keep_if { |provider| provider != :developer }
  end

  # Helper for localized provider name
  def self.provider_name(provider)
    I18n.t(provider, scope: 'account.provider_name')
  end

  # Validations

  validates :provider,
            presence: true,
            inclusion: { in: PROVIDERS }

  validates :uid,
            presence: true,
            uniqueness: { scope: :provider }

  validates :user_id,
            presence: true

  # Instance Methods

  # Personal UID display, based off provider
  def account_uid
    # Display Name for Facebook and Google - Test User
    account_uid ||= name if provider == 'facebook' || provider =~ /google/
    if nickname && provider == 'twitter'
      # Display Handle for Twitter - @testuser
      account_uid ||= nickname =~ /\A@/ ? nickname : "@#{nickname}"
    end
    # Display Nickname for GitHub - testuser
    account_uid ||= nickname if provider == 'github'
    # Display Generic UID as fallback
    account_uid || uid
  end

  # Accounts can be orphaned to prevent sign in
  def enabled?
    user.present?
  end

  def profile_picture(_size = 128)
    image
  end

  def provider_name
    # Use Translated Provider name
    Account.provider_name(provider)
  end

  # Removes all oauth credentials from account
  def remove_oauth_credentials
    self.oauth_token = nil
    self.oauth_secret = nil
    self.oauth_expires_at = nil
  end

  # Update Account properties from OAuth data
  def update_from_auth_hash(data)
    update_account_info data['info']
    update_oauth_credentials data['credentials']
    update_provider_meta_data data
    self
  end

  def update_and_save_from_auth_hash(auth_hash)
    update_from_auth_hash(auth_hash)
    unless save
      error_messages = errors.full_messages.join(', ')
      logger.error "Unable to update account (#{provider}##{uid}): #{error_messages}"
    end
    self
  end

  protected

  # Updates Common Account information
  def update_account_info(info)
    self.name = info['name']
    self.email = info['email']
    self.nickname = info['nickname']
    self.image = info['image']
  end

  # Updates Oauth Credentials
  def update_oauth_credentials(credentials)
    if credentials
      self.oauth_token = credentials['token']
      self.oauth_secret = credentials['secret']
      self.oauth_expires_at = (expires_at = credentials['expires_at']) ? Time.at(expires_at) : nil
    else
      remove_oauth_credentials
    end
  end

  # Updates provider specific information
  # FIXME: Separate Accounts
  def update_provider_meta_data(data)
    info = data['info']
    urls = info['urls']
    if provider == 'facebook'
      self.website = urls && urls['Facebook']
    elsif provider == 'twitter'
      self.website = urls && urls['Twitter']
    elsif provider == 'github'
      self.website = urls && urls['Github']
    else
      self.website = nil
    end
  end
end
