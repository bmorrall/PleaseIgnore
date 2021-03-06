module AuthenticationTokens
  # Finds users with expired authentication tokens and purges them
  class PurgeOldTokensJob < ActiveJob::Base
    include Workers::BackgroundJob

    queue_as Workers::LOW_PRIORITY

    def perform
      users.find_each { |user| Tiddle.purge_old_tokens(user) }
    end

    protected

    def maximum_tokens_per_user
      Tiddle::TokenIssuer::MAXIMUM_TOKENS_PER_USER
    end

    def users
      User.joins(:authentication_tokens)
          .group('users.id')
          .having('count(authentication_tokens) > ?', maximum_tokens_per_user)
    end
  end
end
