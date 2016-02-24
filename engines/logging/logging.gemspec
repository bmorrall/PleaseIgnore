$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'logging/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'logging'
  s.version     = Logging::VERSION
  s.authors     = ['Ben Morrall']
  s.email       = ['bemo56@hotmail.com']
  s.homepage    = 'https://github.com/bmorrall/PleaseIgnore'
  s.summary     = 'Provides Shared Logging code.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.5.1'

  # Reduces noise from Rails logger
  s.add_dependency 'lograge'
  s.add_dependency 'logstash-event'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'simplecov'
end
