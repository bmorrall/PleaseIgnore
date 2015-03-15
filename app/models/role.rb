# Role class used with User to determine access to resources
#
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
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
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

  concerning :RoleVersioning do
    included do
      # Add PaperTrail Versioning, only for unexpected event types
      has_paper_trail(
        on: [:update],
        meta: {
          item_owner: :item_owner
        }
      )
    end

    def item_owner
      resource
    end
  end
end
