require 'English'

def command(*args)
  system(*args)
  fail "Unable to run command #{args.join(' ')}" unless $CHILD_STATUS.success?
end
