module Security
  # Provides a Generator to setup Security
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_initializer_file
      copy_file 'initializer.rb', 'config/initializers/security.rb'
    end

    def copy_request_specs
      copy_file 'csp_report_spec.rb', 'spec/requests/security/csp_report_spec.rb'
      copy_file 'hpkp_reports_spec.rb', 'spec/requests/security/hpkp_reports_spec.rb'
      copy_file 'secure_headers_spec.rb', 'spec/requests/security/secure_headers_spec.rb'
    end

    def configure_routes
      route "mount Security::Engine => '/security'"
    end
  end
end
