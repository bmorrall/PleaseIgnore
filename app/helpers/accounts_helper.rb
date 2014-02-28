module AccountsHelper

  # List of enabled providers
  def omniauth_providers
    @omniauth_providers ||= Account::omniauth_providers.map { |provider| provider.to_s }
  end

  def account_icon(account)
    provider_icon account.provider
  end

  def provider_icon(provider)
    icon_name = provider_class(provider)
    icon_name = "user" if provider == 'developer'
    fa(icon_name)
  end

  def provider_name(provider)
    Account::provider_name(provider)
  end

  def provider_class(provider)
    return 'google-plus' if provider =~ /google/
    provider
  end

end
