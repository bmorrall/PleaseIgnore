class Contact
  include ActiveModel::Model

  attr_accessor(
    :name,
    :email,
    :body,
    :referer
  )

  validates_presence_of :name

  validates_presence_of :email
  # validates_format_of :email, :with => email_regexp

  validates_presence_of :body

  def attributes
    {
      name: name,
      email: email,
      body: body,
      referer: referer
    }
  end

end