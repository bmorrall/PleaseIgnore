# Accounts Helper
# Provides methods to help with rendering accounts in views
module AccountsHelper
  # Decorate an array of accounts with AccountDecorator
  #
  # @param accounts [Array] Account objects to be decorated
  # @yield [accounts] yields a hash of decorated Account objects
  def decorate_account_collection(accounts, &block)
    decorate_collection accounts, AccountDecorator, &block
  end

  # Returns OmniAuth providers in even groups
  def omniauth_provider_groups(&block)
    # Find the most even number of groups
    groups = [5, 4].find { |g| omniauth_providers.count % g == 0 }
    groups ||= 3 # Fall back to 3 per line (yuck)

    # Return providers in groups
    omniauth_providers.in_groups_of groups, false, &block
  end

  # List of enabled providers
  def omniauth_providers
    @omniauth_providers ||= Account.omniauth_providers.map(&:to_s)
  end

  # Icon of the Account provider
  #
  # @param provider [String] provider to provide icon for
  def provider_icon(provider)
    icon_name =
      if provider.to_s =~ /developer/
        'user' # Generic user icon
      else
        provider_class(provider)
      end
    fa(icon_name)
  end

  # Display name for Provider
  #
  # @param provider [String] provider to return name for
  def provider_name(provider)
    Account.provider_name(provider)
  end

  # Wrapper class for Provider
  #
  # @param provider [String] provider to return display class for
  def provider_class(provider)
    if provider.to_s =~ /google/
      'google-plus'
    else
      provider
    end
  end

  # Allows Users to sort a list of accounts
  #
  # @param user [User] user to render accounts list for
  # @yield [] block is passed to a div content tag
  def sortable_accounts_list(user, &block)
    sortable_data = user.accounts.count > 1 ? { sort_path: sort_users_accounts_path } : {}
    content_tag :div, class: 'linked-accounts', data: sortable_data, &block
  end
end
