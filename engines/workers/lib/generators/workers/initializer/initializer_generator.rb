module Workers
  # Provides a Generator to setup Workers
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_file
      copy_file 'initializer.rb', 'config/initializers/workers.rb'
    end

    def copy_sidekiq_config
      copy_file 'sidekiq.yml', 'config/sidekiq.yml'
    end

    def copy_spec_support
      copy_file 'workers_spec_support.rb', 'spec/support/workers.rb'
    end
  end
end
