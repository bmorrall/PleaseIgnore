module Concerns # :nodoc:
  module Users
    # Returns a ActiveRecord::Relation of items belonging to a user
    module BelongsToUser
      extend ActiveSupport::Concern

      included do
        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength

        # Returns all items of a Resource that the user has an assigned role with
        def self.belonging_to(user)
          roles_table = Arel::Table.new(:users_roles)
          role_table = Role.arel_table
          where(
            arel_table[:id].in(
              roles_table.join(role_table)
                         .on(roles_table[:role_id].eq(role_table[:id]))
                         .where(roles_table[:user_id].eq(user.id))
                         .where(role_table[:resource_type].eq(name))
                         .group(role_table[:resource_id])
                         .project(role_table[:resource_id])
            )
          )
        end

        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
