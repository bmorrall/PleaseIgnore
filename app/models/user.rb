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
#

class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [
    :developer,
    :facebook,
    :twitter,
    :github,
    :google_oauth2
  ]

  # Associations

  has_many :accounts,
    -> { order 'position ASC, accounts.provider ASC' },
    :dependent => :destroy

  # Class Methods

  def self.new_with_session(params, session)
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

  after_create :save_new_session_accounts

  # Instance Methods

  def has_provider_account?(provider)
    accounts.where(provider: provider.to_s).any?
  end

  # List of Accounts that will be saved on create
  def new_session_accounts
    @new_session_accounts ||= []
  end

  # Primary account of user
  def primary_account
    accounts.first
  end

  # Instance Methods (Images)

  def gravatar_image(size=128)
    unless email.blank?
      gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end
  end

  # Picture representation of user
  def profile_picture(size=128)
    account = primary_account
    image ||= account && account.profile_picture(size)
    image ||= gravatar_image(size)
  end

  protected

  # Saves Accounts loaded with session on create
  def save_new_session_accounts
    new_session_accounts.each do |account|
      account.user = self
      logger.error "Unable to save Account: #{account.provider}: #{account.uid}" unless account.save!
    end
  end

  # Colllects auth hashes from all stored providers and adds them to the new_session_accounts temporary list
  def add_accounts_from_session(session)
    %w(facebook twitter github google_oauth2 developer).each do |provider|
      provider_key = "devise.#{provider}_data"

      # Add Omniauth Params to User
      if (data = session[provider_key]) && data["info"]
        self.name = data.info["name"] if name.blank?
        self.email = data.info["email"] if email.blank?

        # Add a new session
        self.new_session_accounts << Account.new_with_auth_hash(data, provider)
      end
    end
  end

end
