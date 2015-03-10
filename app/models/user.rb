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
  # Use Rolify to manage roles a user can hold
  rolify

  # Use paranoia to soft delete records (instead of destroying them)
  acts_as_paranoid

  # Attributes

  attr_accessor :terms_and_conditions

  # Validations

  validates :name,
            presence: true

  validates :terms_and_conditions,
            acceptance: true

  # Concerns

  concerning :Accounts do
    included do
      include Concerns::AccountsFromSession

      has_many :accounts,
               -> { order 'position ASC, accounts.type ASC' },
               dependent: :destroy
    end

    # Returns true if the user has at least one Account with `provider`
    #
    # @param provider [String] name of provider
    # @return [Boolean] true if the account has a provider account
    def provider_account?(provider)
      account_type = Account.provider_account_class(provider).name
      accounts.where(type: account_type).any?
    end

    # Primary account of user
    def primary_account
      accounts.first
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

    # Updates default properties from account
    #
    # @param account [Account] updated Account belonging to user
    def update_defaults_from_account(account)
      self.name = account.name if name.blank?
      self.email = account.email if email.blank?
    end
  end

  concerning :Authentication do
    included do
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
    end
  end

  concerning :DeviseOverrides do
    # Checks if the password has not be set to the user, or the password was previous not set
    def no_login_password?
      encrypted_password.blank? || (
        # Password is being added
        encrypted_password_changed? && encrypted_password_change.first.blank?
      )
    end

    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      (!persisted? && new_session_accounts.empty?) ||
        !password.nil? ||
        !password_confirmation.nil?
    end

    # [Devise] Allows valid_password to accept a nil current_password value
    def update_with_password(params, *options)
      @allow_empty_password = true
      super
    ensure
      @allow_empty_password = false
    end

    # Verifies whether an password (ie from sign in) is the user password.
    def valid_password?(password)
      # User is adding a password
      return allow_empty_password? if password.nil? && encrypted_password.blank?
      super # Fallback to standard logic
    end

    protected

    def allow_empty_password?
      !!@allow_empty_password
    end
  end

  concerning :Versioning do
    included do
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

      # Allow soft_deletion restore events to be logged
      include Concerns::RecordRestore

      # Create Restore paper_trail version if a record is restored
      after_restore :record_restore
    end

    # Returns a collection of PaperTrail::Version objects that correlates to changes
    # made by the user
    def related_versions
      PaperTrail::Version.where "(item_type = ? AND item_id = ?) OR \
                                 (item_type = ? AND item_id IN (?))",
                                'User', id,
                                'Account', accounts.with_deleted.pluck(:id)
    end
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
end
