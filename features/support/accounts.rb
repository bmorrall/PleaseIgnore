# Providers Helpers for handling multiple account providers
module AccountsHelpers
  # @param provider_name [String] Human Readable name of provider
  # @return [Symbol] common name of provider
  def provider_from_name(provider_name)
    # Create a array with { human_name => common_name }
    @human_names_as_symbols ||= begin
      values = {}
      Account::PROVIDERS.each do |provider|
        name = Account.provider_name(provider)
        values[name] = provider.to_sym
      end
      values
    end

    # Lookup Human Name to Symbol value
    @human_names_as_symbols[provider_name]
  end
end

World(AccountsHelpers)
