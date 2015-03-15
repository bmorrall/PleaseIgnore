# == Schema Information
#
# Table name: organisations
#
#  id         :integer          not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organisations_on_permalink  (permalink) UNIQUE
#
class Organisation < ActiveRecord::Base
  RESTRICTED_PERMALINK_VALUES = %w(
    about
    admin
    announce
    contact
    privacy
    sidekiq
    users
    terms
    wp-admin
    wp-content
  )

  before_validation :assign_permalink_from_name, on: :create

  # Allow Rolify to Assign Roles
  resourcify

  validates :name, presence: true

  validates :permalink,
            exclusion: { in: RESTRICTED_PERMALINK_VALUES },
            format: { with: /\A[a-z0-9]+(\-[a-z0-9]+)*\z/ }, # a-z, 0-9, single dashes within
            presence: true,
            uniqueness: true

  # [ActiveModel] Changes default parameter to be permalink
  def to_param
    permalink
  end

  protected

  # Assigns permalink to a valid string based off name if it hasn't been assigned by the user
  def assign_permalink_from_name
    self.permalink = nil unless permalink?
    self.permalink ||= (name || '').safe_permalink
  end
end
