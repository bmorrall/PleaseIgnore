# Accounts belong to a User and contains all stored account data based on provider
#
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
class Account < ActiveRecord::Base
  # All available account provider types
  PROVIDERS = %w(facebook twitter github google_oauth2 developer).freeze

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
    # @param auth_hash [Hash] Hash containg payload from Omniauth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] Account matching `auth_hash` or nil
    # @raise [ArgumentError] if the `expected_provider` doesn't match the `auth_hash` provider
    def find_for_oauth(auth_hash, expected_provider = nil)
      provider = auth_hash.provider
      if expected_provider && provider != expected_provider
        # Provider from hash doesn't match expected values
        fail ArgumentError,
             "Provider (#{provider}) doesn't match expected value: #{expected_provider}"
      end

      provider_account_class(provider).find_by_uid(auth_hash.uid).tap do |account|
        account.send(:update_and_save_from_auth_hash, auth_hash) if account
      end
    end

    # Creates a new Account from an OmniAuth hash
    #
    # @param auth_hash [Hash] Hash containg payload from Omniauth
    # @param expected_provider [String] runs check to ensure `auth_hash` is from expected provider
    # @return [Account] a new Account containing extracted data from `auth_hash`
    # @raise [ArgumentError] if the `expected_provider` doesn't match the `auth_hash` provider
    def new_with_auth_hash(auth_hash, expected_provider = nil)
      provider = auth_hash['provider']
      if expected_provider && provider != expected_provider
        # Provider from hash doesn't match expected values
        fail ArgumentError,
             "Provider (#{provider}) doesn't match expected value: #{expected_provider}"
      end

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
    def provider_account_class(provider)
      @provider_account_class ||= {}
      @provider_account_class[provider] ||= begin
        fail ArgumentError, "Unknown provider: #{provider}" unless PROVIDERS.include? provider
        "Accounts::#{provider.classify}".constantize
      end
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

  # Callbacks

  concerning :Versioning do
    included do
      # Use paper_trail to track changes to unexpected values
      has_paper_trail(
        only: [
          :user_id,
          :type
        ],
        ignore: [
          :name,
          :nickname,
          :image,
          :website,
          :deleted_at
        ]
      )

      # Allow soft_deletion restore events to be logged
      include Concerns::RecordRestore

      # Create Restore paper_trail version if a record is restored
      after_restore do
        record_restore
        user.touch # Ensure the user is touched
      end
    end
  end

  # Instance Methods

  # @return [String] unique id of account, scoped to provider
  def account_uid
    fail NotImplementedError
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
    image # use default image attribute
  end

  # @return [String] Common name for Account Provider
  def provider
    fail NotImplementedError
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
  # @param auth_hash [Hash] Hash containg payload from Omniauth
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
  # @param auth_hash [Hash] Hash containg payload from Omniauth
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
