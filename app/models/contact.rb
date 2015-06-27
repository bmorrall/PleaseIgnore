# Contact Model
# Contains validations for submitting a Contact Request
class Contact
  include ActiveModel::Model

  # Associations

  # @return [String] name of contact making request
  attr_accessor :name

  # @return [String] email of contact making request
  attr_accessor :email

  # @return [String] message body
  attr_accessor :body

  # @return [String] referer url used to visit contact page
  attr_accessor :referer

  # @return [String] user_agent of the signed in user
  attr_accessor :user_agent

  # Validations

  validates :name, presence: true

  validates :email, presence: true
  # validates :email, format: { with: email_regexp }

  validates :body, presence: true

  # Instance Methods

  # @return [Hash] attributes to be sent to SupportMailer
  def attributes
    {
      name: name,
      email: email,
      body: body,
      referer: referer,
      user_agent: user_agent
    }
  end

  # Assigns default values based on `user`
  #
  # @param user [User] User to be included with contact request
  def user=(user)
    self.email = user.email
    self.name = user.name
  end
end
