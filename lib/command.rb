
def command(*args)
  system(*args)
  # rubocop:disable Style/SpecialGlobalVars
  fail "Unable to run command #{args.join(' ')}" unless $?.exitstatus == 0
  # rubocop:enable Style/SpecialGlobalVars
end
