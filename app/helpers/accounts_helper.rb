module AccountsHelper

  def account_icon(account)
    provider_icon account.provider
  end

  def provider_icon(provider)
    icon_name = provider_class(provider)
    icon_name = "user" if provider == 'developer'
    content_tag :id, nil, class: "fa fa-#{icon_name}"
  end

  def provider_name(provider)
    Account::provider_name(provider)
  end

  def provider_class(provider)
    return 'google-plus' if provider =~ /google/
    provider
  end

end