# Responder used for Controllers that update the current user profile
class UsersResponder < ApplicationResponder
  require 'responders/user_profile_redirect_responder'
  include Responders::UserProfileRedirectResponder
end
