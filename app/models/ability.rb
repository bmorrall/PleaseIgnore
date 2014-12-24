# Ability file for CanCan(Can)
# Defines permissions for Users of the front end system
class Ability
  include CanCan::Ability

  # Initialises Abilties available to `user`.
  # Abilities anr enabled/disabled based on User#roles.
  #
  # @param user [User, nil] user to be interrogated for allowed roles
  def initialize(user)
    user ||= User.new

    # TODO: Basic User Abilities
    can :create, Contact

    return if user.has_role? :banned

    # Restrictable Visitor Abilities
    can :create, Account

    return unless user.persisted?

    # Authenticated User Abilties
    can [:update, :sort, :destroy], Account, user_id: user.id
  end
end
