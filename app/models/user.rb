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

      %w(facebook twitter github google_oauth2 developer).each do |provider|
        provider_key = "devise.#{provider}_data"

        # Add Omniauth Params to User
        if (data = session[provider_key]) && session[provider_key]["info"]
          user.name = data.info["name"] if user.name.blank?
          user.email = data.info["email"] if user.email.blank?

          # Add a new session
          user.new_session_accounts << Account.new_with_auth_hash(data, provider)
        end
      end

    end
  end

  # Validations

  validates :name,
    presence: true

  validates :terms_and_conditions,
    acceptance: true

  # Callbacks

  after_create :save_new_session_accounts!

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

  # Picture representation of user
  def profile_picture(size=128)
    account = primary_account
    image ||= account && account.profile_picture(size)
    image ||= gravatar_image(size)
  end

  protected

  def gravatar_image(size)
    if email.present?
      # Fall back to Gravatar
      gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end
  end

  # Saves Accounts loaded with session on create
  def save_new_session_accounts!
    new_session_accounts.each do |account|
      account.user = self
      logger.error "Unable to save Account: #{account.provider}: #{account.uid}" unless account.save!
    end
  end

end
