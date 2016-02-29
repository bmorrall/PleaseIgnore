$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'users/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'users'
  s.version     = Users::VERSION
  s.authors     = ['Ben Morrall']
  s.email       = ['bemo56@hotmail.com']
  s.homepage    = 'https://github.com/bmorrall/PleaseIgnore'
  s.summary     = 'Provides Shared Logging code.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.5.1'
  s.add_dependency 'workers'

  # Use Devise to handle authentication
  s.add_dependency 'devise', '~> 3.5.6'

  # Soft Delete Critical Records
  s.add_dependency 'paranoia', '2.1.3'

  # Use Rolify to manage roles a user can hold
  s.add_dependency 'rolify'

  # Send Devise mail through ActiveJob
  s.add_dependency 'devise-async'
  s.add_dependency 'devise-async-activejob'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
end
