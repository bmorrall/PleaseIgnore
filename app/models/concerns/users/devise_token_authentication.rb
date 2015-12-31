module Concerns
  module Users
    # Allows for Authentication Token Authentication for app
    module DeviseTokenAuthentication
      extend ActiveSupport::Concern

      included do
        devise(:token_authenticatable)

        # Authentications are used for api authentication
        has_many :authentication_tokens,
                 dependent: :destroy,
                 foreign_key: :user_id
      end
    end
  end
end
