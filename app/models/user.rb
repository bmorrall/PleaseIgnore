class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true

  def facebook_login?
    false # TODO: Implement OAuth
  end

  def github_login?
    false # TODO: Implement OAuth
  end

  def google_login?
    false # TODO: Implement OAuth
  end

  def twitter_login?
    false # TODO: Implement OAuth
  end

  def email_required?
    !(facebook_login? || github_login? || google_login? || twitter_login?)
  end

  def password_required?
    email_required? && super
  end

  def profile_picture(size=128)
    if email.present?
      gravatar_id = Digest::MD5.hexdigest(email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end
  end

end
