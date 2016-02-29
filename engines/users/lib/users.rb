require 'devise'
require 'devise/async'
require 'devise-async-activejob'
require 'rolify'
require 'paranoia'

require 'gravatar'
require 'users/engine' if defined?(Rails)

# String Methods
require 'core_extensions/string/safe_permalink'
require 'core_extensions/string/transliterations'
String.include CoreExtensions::String::SafePermalink
String.include CoreExtensions::String::Transliterations

# Provides Authenticatable Users model
module Users
end
