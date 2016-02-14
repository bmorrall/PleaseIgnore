require 'English'

def command(*args)
  system(*args)
  raise "Unable to run command #{args.join(' ')}" unless $CHILD_STATUS.success?
end
