json.array!(@users_authentication_tokens) do |users_authentication_token|
  json.extract! users_authentication_token, :id
  json.url users_authentication_token_url(users_authentication_token, format: :json)
end
