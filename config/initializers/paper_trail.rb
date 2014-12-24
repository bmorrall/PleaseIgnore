# Set whodunnint for non-ActionController changes
if defined?(::Rails::Console)
  # Keep track of console users
  PaperTrail.whodunnit = "#{`whoami`.strip}: console"
elsif File.basename($PROGRAM_NAME) == 'rake'
  # Keep track of rake tasks
  PaperTrail.whodunnit = "#{`whoami`.strip}: rake #{ARGV.join ' '}"
end