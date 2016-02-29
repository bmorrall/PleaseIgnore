# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_id   :integer
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#

# Role class used with User to determine access to resources
#
class Role < ActiveRecord::Base
  # All available roles to Users
  ROLES = %w(admin banned).freeze

  # Roles avaliable to an Ownable Resources
  OWNABLE_RESOURCE_ROLES = %w(owner).freeze

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  validates :name, inclusion: { in: ROLES, unless: :resource_type? }
  validates :name, inclusion: { in: OWNABLE_RESOURCE_ROLES, if: :resource_type? }

  scopify
end
