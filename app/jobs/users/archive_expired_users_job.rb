module Users
  # Users that have been soft deleted for more than two months:
  # - have their abilities removed
  # - all details, aside from name removed
  class ArchiveExpiredUsersJob < ActiveJob::Base
    include Rollbar::ActiveJob

    queue_as :low_priority

    # Use `ArchiveExpiredUsersJob.perform_later` to invoke
    # @api private
    # @return [Number] the number of users that were archived
    def perform
      archived_count = 0
      expired_users_with_email.find_each do |user|
        archived_count += 1 if archive_user(user)
      end
      expired_users_with_accounts.find_each do |user|
        archived_count += 1 if archive_user(user)
      end
      archived_count
    end

    # Returns the expired users to be archived
    # @api private
    # @return [ActiveRecord::Collection] Users safe to archive
    def expired_users_with_email
      @expired_users_with_email ||= User.expired.where.not(email: nil)
    end

    def expired_users_with_accounts
      @expired_users_with_accounts ||= User.expired
                                           .joins(:accounts)
                                           .having('count(accounts) > 0')
                                           .group('users.id')
    end

    protected

    # Trip
    # @api private
    # @return [Boolean] true if the user was archived, false if there was any exceptions
    def archive_user(user)
      Users::ArchiveExpiredUser.call(user)
      true
    rescue ActiveRecord::RecordInvalid => e
      Logging.log_error(e, user_id: user.id, errors: user.errors.to_h)
      false
    end
  end
end
