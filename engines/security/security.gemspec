$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'security/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'security'
  s.version     = Security::VERSION
  s.authors     = ['Ben Morrall']
  s.email       = ['bemo56@hotmail.com']
  s.homepage    = 'https://github.com/bmorrall/PleaseIgnore'
  s.summary     = 'Provides Shared Security code.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.5.1'
  s.add_dependency 'workers'
  s.add_dependency 'logging'

  s.add_dependency 'secure_headers', '~> 3.0'
  s.add_dependency 'rack-attack'
  s.add_dependency 'sendgrid'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'faker'
end
