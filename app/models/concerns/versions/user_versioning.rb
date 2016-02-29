module Concerns
  module Versions
    # Adds PaperTrail Versioning to the User model
    module UserVersioning
      extend ActiveSupport::Concern

      included do
        # Allow soft_deletion restore events to be logged
        include Concerns::RecordRestore

        # Use paper_trail to track changes to user modifyable values
        has_paper_trail(
          only: [
            :email,
            :name,
            :confirmed_at
          ],
          ignore: [
            :current_sign_in_at,
            :current_sign_in_ip
          ],
          skip: [
            :encrypted_password,
            :reset_password_token,
            :reset_password_sent_at,
            :remember_created_at,
            :sign_in_count,
            :last_sign_in_at,
            :last_sign_in_ip
          ],
          meta: {
            item_owner: :item_owner
          }
        )

        # Create Restore paper_trail version if a record is restored
        after_restore :record_restore

        after_add_for_roles << lambda do |_callback, user, role|
          user.send(:after_add_role, role)
        end
        after_remove_for_roles << lambda do |_callback, user, role|
          user.send(:after_remove_role, role)
        end

        protected

        # Adds a Version on the Role Object indicatating a added role
        def after_add_role(role)
          role.send(:record_create).tap do
            last_version = role.versions.last
            update_role_version_attributes(last_version, role) if last_version.event == 'create'
          end if PaperTrail.enabled? && Role.paper_trail_enabled_for_model?
        end

        # Adds a Version on the Role Object indicating a removeds Role
        def after_remove_role(role)
          role.send(:record_destroy).tap do
            last_version = role.versions.last
            update_role_version_attributes(last_version, role) if last_version.event == 'destroy'
          end if PaperTrail.enabled? && Role.paper_trail_enabled_for_model?
        end

        # Adds extra attributes to the Version
        def update_role_version_attributes(role_version, role)
          return unless role_version && role
          role_version.item_owner = self if role_version.item_owner.nil?
          role_version.meta[:user_id] = id
          role_version.meta[:role] = role.name
          role_version.save!
        end
      end

      # The user is the owner of all changes made to itself
      def item_owner
        self
      end

      # Returns a collection of PaperTrail::Version objects that correlates to changes
      # made by the user
      def related_versions
        PaperTrail::Version.where(item_owner: self)
      end

      # Returns all version changes made by the current user
      def history
        PaperTrail::Version.where('whodunnit = (?) OR whodunnit like (?)', id.to_s, "#{id} %")
      end
    end
  end
end
