Logging.global_params = {
  host: ::Settings.virtual_host || Rails.env,
  dyno: ENV['DYNO']
}.reject { |_k, v| v.nil? }

OmniAuth.config.logger.formatter = Logging.logstash_formatter
