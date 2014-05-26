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

  # Validations

  validates_presence_of :name

  validates_presence_of :email
  # validates_format_of :email, :with => email_regexp

  validates_presence_of :body

  # Instance Methods

  # @return [Hash] attributes to be sent to SupportMailer
  def attributes
    {
      name: name,
      email: email,
      body: body,
      referer: referer
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
