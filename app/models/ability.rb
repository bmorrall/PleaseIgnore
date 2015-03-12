# Ability file for CanCan(Can)
# Defines permissions for Users of the front end system
class Ability
  include CanCan::Ability

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

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
    can [:update, :sort], Account, user_id: user.id
    can :destroy, Account do |account|
      account.user_id == user.id && (!user.no_login_password? || user.accounts.size > 1)
    end

    return unless user.has_role? :admin

    # Admin User Abilities
    can :read, PaperTrail::Version
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
