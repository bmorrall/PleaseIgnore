class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # TODO: Basic User Abilities
    can :create, Contact

    return if user.has_role? :banned

    # Restrictable Visitor Abilities
    can :create, Account

    if user.persisted?
      # Authenticated User Abilties
      can [:update, :destroy], Account, user_id: user.id
    end
  end
end