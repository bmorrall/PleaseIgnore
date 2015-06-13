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

    can :manage, AuthenticationToken #, user_id: user.id

    return if user.has_role? :banned

    # Restrictable Visitor Abilities
    can :create, Account

    return unless user.persisted?

    # Authenticated User Abilties
    grant_account_abilities(user)
    grant_organisation_abilities(user)
    grant_version_abilities(user)

    return unless user.has_role? :admin

    # Admin User Abilities
    can [:read, :inspect], PaperTrail::Version
  end

  private

  def grant_account_abilities(user)
    can [:read, :update, :sort], Account, user_id: user.id
    can :destroy, Account do |account|
      account.user_id == user.id && (!user.no_login_password? || user.accounts.size > 1)
    end
  end

  def grant_organisation_abilities(user)
    can :read, Organisation do |organisation|
      user.organisations.where(id: organisation.id).any?
    end
    can [:update, :destroy], Organisation do |organisation|
      user.has_role? :owner, organisation
    end
  end

  def grant_version_abilities(user)
    can :read, PaperTrail::Version do |version|
      version.whodunnit == user.id.to_s ||
        version.whodunnit.try(:starts_with?, "#{user.id} ")
    end
  end
end
