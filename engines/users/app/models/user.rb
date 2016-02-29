# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
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

# User Model
# Contains details of all Users of the Application
#
class User < ActiveRecord::Base
  # Duration until a soft deleted account is flagged as expired
  EXPIRATION_PERIOD = 2.months.freeze

  # Use paranoia to soft delete records (instead of destroying them)
  acts_as_paranoid

  # Use Rolify to manage roles a user can hold
  rolify

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
    :async # Send email through ActiveJob
  )

  # Scopes

  scope :expired, -> { deleted.where('users.deleted_at <= ?', EXPIRATION_PERIOD.ago) }

  # Associations

  # Returns a ActiveRecord::Collection of Organisations
  def organisations
    Organisation.belonging_to(self)
  end

  # Attributes

  attr_accessor :terms_and_conditions

  # Validations

  validates :name,
            presence: true

  validates :terms_and_conditions,
            acceptance: true

  # Helper method for paranoia destroyed users
  def expired?
    deleted_at? && deleted_at <= EXPIRATION_PERIOD.ago
  end

  # Checks if the password has not be set to the user,
  # or the password was previous not set
  def no_login_password?
    encrypted_password.blank? || (
      # Password is being added
      encrypted_password_changed? && encrypted_password_change.first.blank?
    )
  end

  # Devise Overrides

  # [Devise] Ensure user account is active
  def active_for_authentication?
    super && !deleted?
  end

  # [Devise] Allow users to continue using the app without confirming their email addresses
  def confirmation_required?
    false
  end

  # [Devise] Allows users to be saved without an email address if a account has been linked
  def email_required?
    if expired?
      false # Expired users do not have an email address
    else
      super # Users without accounts may require an email address
    end
  end

  # [Devise] Provide a custom message for a soft deleted account
  def inactive_message
    !deleted? ? super : :deleted_account
  end

  # Instance Methods (Images)

  # Provides a fallback Gravatar image based of the User email address
  #
  # @param size [Fixnum] size of the requested image (in px)
  def gravatar_image(size = 128)
    Gravatar.gravatar_image_url(email, size)
  end
end
