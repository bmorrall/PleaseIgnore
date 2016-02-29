# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string           not null
#  name             :string
#  nickname         :string
#  image            :string
#  website          :string
#  oauth_token      :string
#  oauth_secret     :string
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string
#  deleted_at       :datetime
#
# Indexes
#
#  index_accounts_on_deleted_at  (deleted_at)
#  index_accounts_on_user_id     (user_id)
#

# Accounts belong to a User and contains all stored account data based on provider
#
# Represents an OmniAuth connected Account belonging to a {User}
# @abstract Subclass and override {#account_uid} and {#provider} to implement
#   a custom Account class.
class Account < ActiveRecord::Base
  # All available account provider types
  PROVIDERS = %w(facebook twitter github google_oauth2 developer).freeze

  # Error when a auth hash is received for a different provider
  class InvalidProviderError < ::StandardError
    def initialize(provider, expected_provider)
      super "Provider (#{provider}) doesn't match expected value: #{expected_provider}"
    end
  end
  # Error when a auth hash or request has been received for a unknown provider
  class UnknownProviderError < ::StandardError
    def initialize(provider)
      super "Provider (#{provider}) has not been registered"
    end
  end

  # Accounts are instanciated using Sub-Classes controlled by type
  self.inheritance_column = :type

  # Use paranoia to soft delete records (instead of destroying them)
  acts_as_paranoid

  # Associations

  belongs_to :user, touch: true

  # Allow User accounts to be managed as a sorted list
  acts_as_list scope: :user

  # Attributes

  # Email is not saved to database, but stored locally where possible
  # @return [String] email address loaded from OmniAuth
  attr_accessor :email

  # Class Methods

  class << self
    # Finds a existing Account from an OmniAuth hash, and updates from latest details
    #
    # @param auth_hash [OmniAuth::AuthHash] Hash containg payload from OmniAuth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] Account matching `auth_hash` or nil
    # @raise [InvalidProviderError] if the `expected_provider` doesn't match the `auth_hash`
    # @raise [UnknownProviderError] if the `auth_hash` provider hasn't been configured by the app
    def find_for_oauth(auth_hash, expected_provider = nil)
      ensure_expected_provider! auth_hash, expected_provider

      provider = auth_hash['provider']
      account_uid = auth_hash['uid']
      provider_account_class(provider).find_by_uid(account_uid).tap do |account|
        account.send(:update_and_save_from_auth_hash, auth_hash) if account
      end
    end

    # Creates a new Account from an OmniAuth hash
    #
    # @param auth_hash [Hash] Hash containg payload from OmniAuth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] a new Account containing extracted data from `auth_hash`
    # @raise [InvalidProviderError] if the `expected_provider` doesn't match the `auth_hash`
    # @raise [UnknownProviderError] if the `auth_hash` provider hasn't been configured by the app
    def new_with_auth_hash(auth_hash, expected_provider = nil)
      ensure_expected_provider! auth_hash, expected_provider

      provider = auth_hash['provider']
      provider_account_class(provider).new(
        uid: auth_hash['uid']
      ).send(:update_from_auth_hash, auth_hash)
    end

    # @return [Array] Array of all enabled OmniAuth providers as symbols
    def omniauth_providers
      Devise.omniauth_configs.keys.keep_if do |provider|
        provider != :developer || Rails.env.development?
      end
    end

    # Returns provider name as a human readable string
    #
    # @param [String, Symbol] provider Name of Provider
    # @return [String] Provider name localized to `account.provider_name` scope
    def provider_name(provider)
      I18n.t(provider, scope: 'account.provider_name')
    end

    # Returns the Class used for Accounts beloning to `provider
    #
    # @api private
    # @param provider [String] name of provider that Account belongs to
    # @return [Class] Account class used to represent provider accounts
    # @raise [UnknownProviderError] if the `provider` hasn't been configured by the app
    def provider_account_class(provider)
      @provider_account_class ||= {}
      @provider_account_class[provider] ||= begin
        raise UnknownProviderError, provider unless PROVIDERS.include? provider
        "Accounts::#{provider.classify}".constantize
      end
    end

    protected

    # Raise error if provider from auth_hash doesn't match expected_provider
    def ensure_expected_provider!(auth_hash, expected_provider)
      provider = auth_hash['provider']
      return if !expected_provider || provider == expected_provider

      raise InvalidProviderError.new(provider, expected_provider)
    end
  end

  # Validations

  require 'uniqueness_without_deleted_validator'

  # UID is unique to each account type (provider)
  validates :uid,
            presence: true,
            uniqueness_without_deleted: { scope: :type }

  # Users can only have one account per account type (provider)
  validates :user_id,
            presence: true,
            uniqueness_without_deleted: { scope: :type }

  # Instance Methods

  # @return [String] unique id of account, scoped to provider
  def account_uid
    raise NotImplementedError
  end

  # Accounts can be disabled to prevent sign in
  # @return [Boolean] true if the Account is enabled for sign in
  def enabled?
    user.present?
  end

  # Accounts can be disabled to prevent sign in
  # @return [Boolean] true if the Account is disabled
  def disabled?
    user.nil?
  end

  # Account Profile Picture
  # @param [Fixnum] _size Preferred size of the image
  # @return [String] Path to Account Profile Picture or nil
  def profile_picture(_size = 128)
    image # use default image attribute
  end

  # @return [String] Common name for Account Provider
  def provider
    raise NotImplementedError
  end

  # @return [String] Human Readable Account Profile Name
  def provider_name
    Account.provider_name(provider)
  end

  # Removes all oauth credentials from account
  def remove_oauth_credentials
    self.oauth_token = nil
    self.oauth_secret = nil
    self.oauth_expires_at = nil
  end

  protected

  # Update Account properties from OAuth data
  #
  # @api private
  # @param auth_hash [Hash] Hash containg payload from OmniAuth
  def update_from_auth_hash(auth_hash)
    update_account_info auth_hash['info']
    update_oauth_credentials auth_hash['credentials']
    self
  end

  # Attempts to update Account from Auth has and Save.
  #
  # Logs any failed attempts to save.
  #
  # @api private
  # @param auth_hash [Hash] Hash containg payload from OmniAuth
  def update_and_save_from_auth_hash(auth_hash)
    update_from_auth_hash(auth_hash)
    unless save
      messages = errors.full_messages.join(', ')
      logger.error "Unable to update account (#{provider}##{uid}): #{messages}"
    end
    self
  end

  # Updates Common Account information
  #
  # @param info [Hash] OAuth Account Info from OmniAuth
  def update_account_info(info)
    self.name     = info['name']
    self.email    = info['email']
    self.nickname = info['nickname']
    self.image    = info['image']
    self.email    = info['email']
    self.website  = nil # Override to define
  end

  # Updates Oauth Credentials
  #
  # @param credentials [Hash] OAuth Credentials from OmniAuth
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
end

Account.include Concerns::Versions::AccountVersioning
