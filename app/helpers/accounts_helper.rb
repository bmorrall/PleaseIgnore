# Accounts Helper
# Provides methods to help with rendering accounts in views
module AccountsHelper
  # Decorate an array of accounts with AccountDecorator
  def decorate_account_collection(accounts, &block)
    decorate_collection accounts, AccountDecorator, &block
  end

  # Returns Omniauth providers in even groups
  def omniauth_provider_groups(&block)
    # Find the most even number of groups
    groups = [5, 4].find { |g| omniauth_providers.count % g == 0 }
    groups ||= 3 # Fall back to 3 per line (yuck)

    # Return providers in groups
    omniauth_providers.in_groups_of groups, false, &block
  end

  # List of enabled providers
  def omniauth_providers
    @omniauth_providers ||= Account.omniauth_providers.map { |provider| provider.to_s }
  end

  # Icon of the Account provider
  def provider_icon(provider)
    icon_name =
      if provider == :developer
        'user'  # Generic user icon
      else
        provider_class(provider)
      end
    fa(icon_name)
  end

  # Display name for Provider
  def provider_name(provider)
    Account.provider_name(provider)
  end

  # Wrapper class for Provider
  def provider_class(provider)
    if provider.to_s =~ /google/
      'google-plus'
    else
      provider
    end
  end
end
