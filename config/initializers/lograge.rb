Rails.application.configure do
  IGNORED_PARAMS = %w(controller action utf8 _method).freeze

  # Removes restricted values from params
  def filter_params(params)
    params = params.reject do |param|
      param.starts_with?('_') ||
      param == ApplicationController.request_forgery_protection_token.to_s ||
      IGNORED_PARAMS.include?(param)
    end

    filter_parameters = Rails.application.config.filter_parameters
    param_filter = ActionDispatch::Http::ParameterFilter.new(filter_parameters)
    param_filter.filter(params)
  end

  config.lograge.enabled = true

  config.lograge.formatter = Lograge::Formatters::Logstash.new

  config.lograge.custom_options = lambda do |event|
    {
      # Server params
      host: ENV.fetch('VIRTUAL_HOST', Rails.env),
      # Request params
      xhr: event.payload[:xhr],
      params: filter_params(event.payload[:params]),
      # Client params
      ip: event.payload[:ip],
      user_agent: event.payload[:user_agent],
      # Logged in user params
      user: event.payload[:user],
      user_id: event.payload[:user_id]
    }
  end
end
