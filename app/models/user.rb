class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:developer, :facebook, :twitter, :github, :google_oauth2]

  has_many :accounts, -> { order 'accounts.provider ASC' }, :dependent => :destroy
  after_create :save_new_session_accounts!

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

  validates :name, presence: true

  validates :terms_and_conditions, acceptance: true

  def facebook_login?
    accounts.where(:provider => 'facebook').any?
  end

  def github_login?
    accounts.where(:provider => 'github').any?
  end

  def google_login?
    accounts.where(:provider => 'google_oauth2').any?
  end

  def twitter_login?
    accounts.where(:provider => 'twitter').any?
  end

  def email_required?
    !(facebook_login? || github_login? || google_login? || twitter_login?)
  end

  def password_required?
    email_required? && super
  end

  def profile_picture(size=128)
    account = accounts.first
    if account && account.image
      # Use Account Image
      account.image
    elsif email.present?
      # Fall back to Gravatar
      gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end
  end

  def new_session_accounts
    @new_session_accounts ||= []
  end

  protected

  def save_new_session_accounts!
    new_session_accounts.each do |account|
      account.user = self
      logger.error "Unable to save Account: #{account.provider}: #{account.uid}" unless account.save!
    end
  end

end
