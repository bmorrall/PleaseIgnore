# User Model
# Contains details of all Users of the Application
#
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  name                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ActiveRecord::Base
  # Use paranoia to soft delete records (instead of destroying them)
  acts_as_paranoid

  # Attributes

  attr_accessor :terms_and_conditions

  # Associations

  # Returns a ActiveRecord::Collection of Organisations
  def organisations
    Organisation.belonging_to(self)
  end

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
        :confirmable,
        :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :trackable,
        :validatable,
        :async, # Send email through Sidekiq
        :omniauthable,
        :token_authenticatable,
        omniauth_providers: [
          :developer,
          :facebook,
          :twitter,
          :github,
          :google_oauth2
        ]
      )

      # Authentications are used for api authentication
      has_many :authentication_tokens, dependent: :destroy
    end
  end

  concerning :DeviseOverrides do
    # [Devise] Checks if the password has not be set to the user,
    # or the password was previous not set
    def no_login_password?
      encrypted_password.blank? || (
        # Password is being added
        encrypted_password_changed? && encrypted_password_change.first.blank?
      )
    end

    # [Devise] Allow users to continue using the app without confirming their email addresses
    def confirmation_required?
      false
    end

    # [Devise] Checks whether a password is needed or not. For validations only.
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

  concerning :Roles do
    included do
      # Use Rolify to manage roles a user can hold
      rolify after_add: :after_add_role, after_remove: :after_remove_role

      # Adds a Version on the Role Object indicatating a added role
      def after_add_role(role)
        role.send(:record_create).tap do |role_version|
          update_role_version_attributes role_version, role
        end if PaperTrail.enabled? && Role.paper_trail_enabled_for_model?
      end

      # Adds a Version on the Role Object indicating a removeds Role
      def after_remove_role(role)
        role.send(:record_destroy).tap do |role_versions|
          update_role_version_attributes role_versions.last, role # Last is the created item
        end if PaperTrail.enabled? && Role.paper_trail_enabled_for_model?
      end
    end

    protected

    # Adds extra attributes to the Version
    def update_role_version_attributes(role_version, role)
      return unless role_version && role
      role_version.item_owner = self if role_version.item_owner.nil?
      role_version.meta[:user_id] = id
      role_version.meta[:role] = role.name
      role_version.save!
    end
  end

  concerning :Versioning do
    included do
      # Use paper_trail to track changes to user modifyable values
      has_paper_trail(
        only: [
          :email,
          :name,
          :confirmed_at
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
        ],
        meta: {
          item_owner: :item_owner
        }
      )

      # Allow soft_deletion restore events to be logged
      include Concerns::RecordRestore

      # Create Restore paper_trail version if a record is restored
      after_restore :record_restore
    end

    # The user is the owner of all changes made to itself
    def item_owner
      self
    end

    # Returns a collection of PaperTrail::Version objects that correlates to changes
    # made by the user
    def related_versions
      PaperTrail::Version.where(item_owner: self)
    end
  end

  # Instance Methods (Images)

  # Provides a fallback Gravatar image based of the User email address
  #
  # @param size [Fixnum] size of the requested image (in px)
  def gravatar_image(size = 128)
    return if email.blank?

    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&r=PG&d=identicon"
  end
end
