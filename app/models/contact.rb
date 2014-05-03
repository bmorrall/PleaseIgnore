# Contact Model
# Contains validations for submitting a Contact Request
class Contact
  include ActiveModel::Model

  # Associations

  attr_accessor(
    :name,
    :email,
    :body,
    :referer
  )

  # Validations

  validates_presence_of :name

  validates_presence_of :email
  # validates_format_of :email, :with => email_regexp

  validates_presence_of :body

  # Instance Methods

  def attributes
    {
      name: name,
      email: email,
      body: body,
      referer: referer
    }
  end

  # Assigns Properties from `user`
  def user=(user)
    self.email = user.email
    self.name = user.name
  end
end
