class Account < ActiveRecord::Base
  belongs_to :user

  def self.find_for_oauth(auth_hash, force_provider = nil)
    provider = force_provider || auth_hash_provider
    find_by_provider_and_uid(provider, auth_hash.uid).tap do |account|
      unless account.nil?
        account.update_from_auth_hash(auth_hash)
        account.save!
      end
    end
  end

  def self.find_for_facebook_oauth(data)
    find_for_oauth(data, 'facebook')
  end

  def self.new_with_auth_hash(data, force_provider=nil)
    provider = force_provider || data.provider
    Account.new.tap do |account|
      account.provider = provider
      account.uid = data.uid
      account.update_from_auth_hash(data)
    end
  end

  def self.provider_name(provider)
    return "GitHub" if provider == 'github'
    return "Google" if provider =~ /google/
    provider.humanize
  end

  validates :provider, presence: true, inclusion: { in: %w(developer facebook twitter github google_oauth2) }
  validates :uid, presence: true, uniqueness: { :scope => :provider }
  validates :user_id, presence: true

  def enabled?
    user.present?
  end

  def provider_name
    Account::provider_name(provider)
  end

  def account_uid
    account_uid ||= name if provider == 'facebook' || provider =~ /google/
    account_uid ||= nickname =~ /\A@/ ? nickname : "@#{nickname}" if provider == 'twitter'
    account_uid ||= nickname if provider == 'github'
    account_uid ||= uid
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
