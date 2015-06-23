
# http://about.travis-ci.org/docs/user/gui-and-headless-browsers/#RSpec%2C-Jasmine%2C-Cucumber
task :travis do
  require 'command'

  ['rspec spec', 'rake cucumber', 'rake quality'].each do |cmd|
    puts "Starting to run #{cmd}..."
    command("export DISPLAY=:99.0 && bundle exec #{cmd}")
  end
end
