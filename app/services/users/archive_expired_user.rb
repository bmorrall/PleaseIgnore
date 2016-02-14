module Users
  # Removes all personal information from an expired User account (except for name)
  #
  # Archiving the user prevents the user account from every being restored.
  #
  # Will not remove details from the user,
  # unless it has been at least two months since it was deleted.
  class ArchiveExpiredUser
    include Concerns::Service

    # Returns the user being archived
    #
    # @api private
    # @return [User] the user to be archived
    attr_reader :user

    # Create a new ArchiveExpiredUser service to purge all details from `user`
    # @api private
    def initialize(user)
      @user = user
    end

    # Invoke using `User::ArchiveExpiredUser.call(user)`
    # @api private
    # @throws StandardError if the user is not able to be archived safely
    # @return void
    def call
      raise 'Attempted to strip a non-expireable user!' unless safe_to_strip?

      ActiveRecord::Base.transaction do
        user.update_attributes!(
          email: nil,
          confirmed_at: nil
        )
        user.accounts.destroy_all # Remove all accounts
        user.authentication_tokens.destroy_all # Should already be destroyed from initial delete
      end
    end

    # Checks if it is safe to strip a user of all attribetus
    #
    # @api private
    # @return [Boolean] true if it is safe to remove a user
    def safe_to_strip?
      user.email? && user.expired?
    end
  end
end
