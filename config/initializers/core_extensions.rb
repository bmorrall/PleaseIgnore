# Core Extensions added to the app

# String Methods
require 'core_extensions/string/safe_permalink'
require 'core_extensions/string/transliterations'
String.include CoreExtensions::String::SafePermalink
String.include CoreExtensions::String::Transliterations

# View Helpers
require 'helpers/font_awesome_helper'
ActionController::Base.helper FontAwesomeHelper
