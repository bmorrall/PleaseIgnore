class Account < ActiveRecord::Base
  PROVIDERS = %w(developer facebook twitter github google_oauth2)

  # Associations

  belongs_to :user
  acts_as_list scope: :user

  # Class Methods

  # Finds a existing Account from an OmniAuth hash, and updates from latest details
  def self.find_for_oauth(auth_hash, force_provider = nil)
    provider = auth_hash.provider
    if force_provider && provider != force_provider
      # Provider from hash doesn't match expected values
      raise "Provider (#{provider}) doesn't match expected value: #{force_provider}"
    end

    find_by_provider_and_uid(provider, auth_hash.uid).tap do |account|
      unless account.nil?
        account.update_from_auth_hash(auth_hash)
        unless account.save
          errors = account.errors.full_messages.join(', ')
          logger.error "Unable to update account (#{account.uid}): #{errors}"
        end
      end
    end
  end

  # Creates a New Account based off OmniAuth Hash
  def self.new_with_auth_hash(data, force_provider=nil)
    provider = force_provider || data.provider
    Account.new.tap do |account|
      account.provider = provider
      account.uid = data.uid
      account.update_from_auth_hash(data)
    end
  end

  # List of available OmniAuth Providers
  def self.omniauth_providers
    Devise.omniauth_configs.keys.keep_if { |provider| provider != :developer }
  end

  # Humanizes Provider Name
  def self.provider_name(provider)
    return nil if provider.blank?
    return "GitHub" if provider == 'github'
    return "Google" if provider =~ /google/
    provider.humanize
  end

  # Validations

  validates :provider,
    presence: true,
    inclusion: { in: PROVIDERS }

  validates :uid,
    presence: true,
    uniqueness: { :scope => :provider }

  validates :user_id,
    presence: true

  # Instance Methods

  # Personal UID display, based off provider
  def account_uid
    # Display Name for Facebook and Google - Test User
    account_uid ||= name if provider == 'facebook' || provider =~ /google/
    # Display Handle for Twitter - @testuser
    account_uid ||= nickname =~ /\A@/ ? nickname : "@#{nickname}" if nickname && provider == 'twitter'
    # Display Nickname for GitHub - testuser
    account_uid ||= nickname if provider == 'github'
    # Display Generic UID as fallback
    account_uid ||= uid
  end

  # Accounts can be orphaned to prevent sign in
  def enabled?
    user.present?
  end

  def profile_picture(size=128)
    image
  end

  def provider_name
    Account::provider_name(provider)
  end

  # Update Account properties from OAuth data
  def update_from_auth_hash(data)
    self.name = data.info.name
    self.nickname = data.info.nickname
    self.image = data.info.image
    if data.credentials.present?
      self.oauth_token = data.credentials.token
      self.oauth_secret = data.credentials.secret
      if data.credentials.expires_at
        self.oauth_expires_at = Time.at(data.credentials.expires_at)
      end
    end
    if provider == 'facebook'
      self.website = data.info.urls && data.info.urls['Facebook']
    elsif provider == 'twitter'
      self.website = data.info.urls && data.info.urls['Twitter']
    elsif provider == 'github'
      self.website = data.info.urls && data.info.urls['Github']
    end
  end
end
