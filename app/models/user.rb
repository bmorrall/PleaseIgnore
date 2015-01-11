# User Model
# Contains details of all Users of the Application
#
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  name                   :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#
class User < ActiveRecord::Base
  # Use paper_trail to track changes to user modifyable values
  has_paper_trail(
    only: [
      :email,
      :name
    ],
    ignore: [
      :current_sign_in_at,
      :current_sign_in_ip
    ],
    skip: [
      :encrypted_password,
      :reset_password_token,
      :reset_password_sent_at,
      :remember_created_at,
      :sign_in_count,
      :last_sign_in_at,
      :last_sign_in_ip
    ]
  )

  # Use Rolify to manage roles a user can hold
  rolify

  # Use paranoia to soft delete records (instead of destroying them)
  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :trackable,
    :validatable,
    :async, # Send email through Sidekiq
    :omniauthable,
    omniauth_providers: [
      :developer,
      :facebook,
      :twitter,
      :github,
      :google_oauth2
    ]
  )

  # Allow soft_deletion restore events to be logged
  include Concerns::RecordRestore

  # Associations

  has_many :accounts,
           -> { order 'position ASC, accounts.type ASC' },
           dependent: :destroy

  # Class Methods

  # [Devise] Returns a new user from Session data.
  # Saves stored accounts to #new_session_accounts if auth hash is found in session.
  #
  # @param _params [Hash] params from Controller request
  # @param session [Hash] stored Guest session data
  # @return [User] new User object with Accounts loaded from `session`
  def self.new_with_session(_params, session)
    super.tap do |user|
      user.send :add_accounts_from_session, session
    end
  end

  # Validations

  validates :name,
            presence: true

  validates :terms_and_conditions,
            acceptance: true

  # Callbacks

  # Save built accounts that have been imported from a session
  after_create :save_new_session_accounts

  # Create Restore paper_trail version if a record is restored
  after_restore :record_restore

  # Instance Methods

  # Returns true if the user has at least one Account with `provider`
  #
  # @param provider [String] name of provider
  # @return [Boolean] true if the account has a provider account
  def provider_account?(provider)
    account_type = Account.provider_account_class(provider).name
    accounts.where(type: account_type).any?
  end

  # @return [Array] Array of Accounts that will be saved on create
  def new_session_accounts
    @new_session_accounts ||= []
  end

  # Primary account of user
  def primary_account
    accounts.first
  end

  # Instance Methods (Images)

  # Provides a fallback Gravatar image based of the User email address
  #
  # @param size [Fixnum] size of the requested image (in px)
  def gravatar_image(size = 128)
    return if email.blank?

    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end

  # Picture representation of user.
  # Attempts to use accunt image, but falls back to #gravatar_image if not present
  #
  # @param size [Fixnum] size of the requested image (in px)
  def profile_picture(size = 128)
    account = primary_account
    image ||= account && account.profile_picture(size)
    image || gravatar_image(size)
  end

  protected

  # Collects auth hashes from all stored providers and adds them to the new_session_accounts
  # temporary list.
  def save_new_session_accounts
    new_session_accounts.each do |account|
      account.user = self
      next if account.save

      # Add errors to model and raise exception
      logger.error "Unable to save Account: #{account.provider}: #{account.uid}"
      error_message = "Unable to add your #{Account.provider_name(account.provider)} account"
      errors.add :base, error_message
      fail ActiveRecord::RecordInvalid, account
    end
  end

  # Collections auth hashes from all stored providers and adds them to
  # the `new_session_accounts` temporary list
  #
  # @param session [Hash] Guest session containg provider auth hashes
  def add_accounts_from_session(session)
    Account::PROVIDERS.each do |provider|
      provider_key = "devise.#{provider}_data"
      next unless (data = session[provider_key])

      # Add account to new session accounts
      account = Account.new_with_auth_hash(data, provider)
      update_defaults_from_account account
      new_session_accounts << account
    end
  end

  # Updates default properties from account
  #
  # @param account [Account] updated Account belonging to user
  def update_defaults_from_account(account)
    self.name = account.name if name.blank?
    self.email = account.email if email.blank?
  end
end
