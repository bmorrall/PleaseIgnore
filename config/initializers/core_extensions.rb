# Core Extensions added to the app
require 'core_extensions/string/safe_permalink'
require 'core_extensions/string/transliterations'

String.include CoreExtensions::String::SafePermalink
String.include CoreExtensions::String::Transliterations
