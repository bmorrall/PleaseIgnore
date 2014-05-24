namespace :quality do
  # Rubocop Rake Task
  begin
    require 'rubocop/rake_task'
  rescue LoadError
    warn "rubocop not available, rubocop task not provided."
  else
    desc 'Run rubocop static code analyser'
    Rubocop::RakeTask.new(:rubocop) do |task|
      task.patterns = %w(app config features lib spec)
      task.fail_on_error = true
    end
  end
end

desc "Run code quality metrics on project"
task quality: %w(quality:rubocop)
