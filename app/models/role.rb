# Role class used with User to determine access to resources
#
# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  resource_id   :integer
#  resource_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
class Role < ActiveRecord::Base
  # All available roles to Users
  ROLES = %w(admin banned)

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  validates :name, inclusion: { in: ROLES }

  scopify
end
