# Methods for integrating with Gravatar image service (https://en.gravatar.com/)
class Gravatar
  # Returns a secure Gravatar Image url for `email`
  #
  # @api public
  # @example Gravatar.gravatar_image_url('email@example.com')
  # @param email [String] email for the user
  # @param size [Number] the dimensions in pixels of the square image
  # @return an avatar image url from the Gravatar service
  def self.gravatar_image_url(email, size = 128)
    return if email.blank?

    gravatar_id = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}.png?s=#{size}&r=PG&d=identicon"
  end
end
