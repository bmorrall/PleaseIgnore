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
    grant_account_abilities(user)
    grant_organisation_abilities(user)

    return unless user.has_role? :admin

    # Admin User Abilities
    can :read, PaperTrail::Version
  end

  private

  def grant_account_abilities(user)
    can [:update, :sort], Account, user_id: user.id
    can :destroy, Account do |account|
      account.user_id == user.id && (!user.no_login_password? || user.accounts.size > 1)
    end
  end

  def grant_organisation_abilities(user)
    can :create, Organisation
    can :read, Organisation, id: user.organisation_ids
    can [:update, :destroy], Organisation do |organisation|
      user.has_role? :owner, organisation
    end
  end
end
