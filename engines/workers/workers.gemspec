$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'workers/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'workers'
  s.version     = Workers::VERSION
  s.authors     = ['Ben Morrall']
  s.email       = ['bemo56@hotmail.com']
  s.homepage    = 'https://github.com/bmorrall/PleaseIgnore'
  s.summary     = 'Provides Background Worker shells and configuration.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 4.2.5.1'
  s.add_dependency 'logging'

  # Use Sidekiq for background jobs
  s.add_dependency 'sidekiq', '~> 4.1.0'
  s.add_dependency 'redis-namespace' # Required for Sidekiq namespace

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'simplecov'
end
