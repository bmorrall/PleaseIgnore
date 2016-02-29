# Add Users Concerns
Rails.application.config.after_initialize do
  require 'user'

  User.include Concerns::Users::DeviseTokenAuthentication
  User.include Concerns::Users::DeviseAccountAuthentication
  User.include Concerns::Versions::UserVersioning

  Role.include Concerns::Versions::RoleVersioning
end
