# Accounts belong to a User and contains all stored account data based on provider
#
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

  # Email is not saved to database, but stored locally where possible
  attr_accessor :email

  # Class Methods

  class << self
    # Finds a existing Account from an OmniAuth hash, and updates from latest details
    #
    # @param auth_hash [Hash] Hash containg payload from Omniauth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] Account matching `auth_hash` or nil
    # @raise [IllegalArgumentException] if `auth_hash` is not from `expected_provider`
    def find_for_oauth(auth_hash, expected_provider = nil)
      provider = auth_hash.provider
      if expected_provider && provider != expected_provider
        # Provider from hash doesn't match expected values
        fail ArgumentError,
             "Provider (#{provider}) doesn't match expected value: #{expected_provider}"
      end

      find_by_provider_and_uid(provider, auth_hash.uid).tap do |account|
        account.send(:update_and_save_from_auth_hash, auth_hash) if account
      end
    end

    # Creates a new Account from an OmniAuth hash
    #
    # @param auth_hash [Hash] Hash containg payload from Omniauth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] a new Account containing extracted data from `auth_hash`
    # @raise [IllegalArgumentException] if `auth_hash` is not from `expected_provider`
    def new_with_auth_hash(auth_hash, expected_provider = nil)
      provider = auth_hash['provider']
      if expected_provider && provider != expected_provider
        # Provider from hash doesn't match expected values
        fail ArgumentError,
             "Provider (#{provider}) doesn't match expected value: #{expected_provider}"
      end

      Account.new(
        provider: provider,
        uid: auth_hash['uid']
      ).send(:update_from_auth_hash, auth_hash)
    end

    # Lists all available OmniAuth Providers
    # @return [Array] Array of OmniAuth provider symbols
    def omniauth_providers
      Devise.omniauth_configs.keys.keep_if do |provider|
        provider != :developer || Rails.env.development?
      end
    end

    # Returns provider name as a human readable string
    # @param [String, Symbol] provider Name of Provider
    # @return [String] Provider name localized to `account.provider_name` scope
    def provider_name(provider)
      I18n.t(provider, scope: 'account.provider_name')
    end
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
      account_uid ||= twitter_account_uid
    end
    # Display Nickname for GitHub - testuser
    account_uid ||= nickname if provider == 'github'
    # Display Generic UID as fallback
    account_uid || uid
  end

  # Accounts can be disabled to prevent sign in
  # @return [Boolean] true if the Account is enabled for sign in
  def enabled?
    user.present?
  end

  # Account Profile Picture
  # @param [Fixnum] _size Preferred size of the image
  # @return [String] Path to Account Profile Picture or nil
  def profile_picture(_size = 128)
    image
  end

  # Human Readable Account Profile Name
  # @return [String] Account.provider_name return value with current provider
  def provider_name
    # Use Translated Provider name
    Account.provider_name(provider)
  end

  # Removes all oauth credentials from account
  # @return self
  def remove_oauth_credentials
    self.oauth_token = nil
    self.oauth_secret = nil
    self.oauth_expires_at = nil
    self
  end

  protected

  # Update Account properties from OAuth data
  # @api private
  # @param auth_hash [Hash] Hash containg payload from Omniauth
  # @return self
  def update_from_auth_hash(auth_hash)
    update_account_info auth_hash['info']
    update_oauth_credentials auth_hash['credentials']
    update_provider_meta_data auth_hash
    self
  end

  # Attempts to update Account from Auth has and Save.
  #
  # Logs any failed attempts to save
  #
  # @api private
  # @param auth_hash [Hash] Hash containg payload from Omniauth
  # @return self
  def update_and_save_from_auth_hash(auth_hash)
    update_from_auth_hash(auth_hash)
    unless save
      messages = errors.full_messages.join(', ')
      logger.error "Unable to update account (#{provider}##{uid}): #{messages}"
    end
    self
  end

  # Returns nickname, ensuring it starts with a '@'
  def twitter_account_uid
    nickname =~ /\A@/ ? nickname : "@#{nickname}" if nickname?
  end

  # Updates Common Account information
  def update_account_info(info)
    self.name = info['name']
    self.email = info['email']
    self.nickname = info['nickname']
    self.image = info['image']
    self.email = info['email']
  end

  # Updates Oauth Credentials
  def update_oauth_credentials(credentials)
    if credentials
      self.oauth_token = credentials['token']
      self.oauth_secret = credentials['secret']

      expires_at = credentials['expires_at']
      self.oauth_expires_at = expires_at ? Time.at(expires_at) : nil
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
