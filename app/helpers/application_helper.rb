module ApplicationHelper

  def header_nav_class(path)
    current_page?(path) ? 'active' : nil
  end

  def message_alert_class(name)
    if name == :notice
      'success'
    elsif name == :warning
      'warning'
    elsif name == :info
      'info'
    else
      'danger'
    end
  end

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
