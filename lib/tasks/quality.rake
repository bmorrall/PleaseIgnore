namespace :quality do
  # Cane Rake Task
  begin
    require 'cane/rake_task'
  rescue LoadError
    warn "cane not available, cane task not provided."
  else
    desc "Run cane to check quality metrics"
    Cane::RakeTask.new(:cane) do |cane|
      cane.abc_max       = 16
      cane.no_doc        = true
      cane.style_glob    = './{app,config,feature,lib,spec}/**/*.rb'
      cane.style_measure = 100
    end
  end

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

  # Yardstick Rake Tasks
  namespace :yardstick do
    # Measure YARD Coverage
    begin
      require 'yardstick/rake/measurement'
    rescue LoadError
      warn "yardstick not available, yardstick task not provided."
    else
      options = YAML.load_file('config/yardstick.yml')

      desc 'Measure YARD documentation coverage'
      Yardstick::Rake::Measurement.new(:measure, options) do |measurement|
        measurement.output = 'measurements/report.txt'
      end
    end

    # Verify Coverage %
    begin
      require 'yardstick/rake/verify'
    rescue LoadError
      warn "yardstick not available, yardstick task not provided."
    else
      options = YAML.load_file('config/yardstick.yml')

      desc 'Verify documentation coverage'
      Yardstick::Rake::Verify.new(:verify, options)
    end
  end
  desc 'Verify YARD coverage on project'
  task yardstick: %w(yardstick:verify)
end

desc "Run code quality metrics on project"
task quality: %w(quality:cane quality:rubocop quality:yardstick)
