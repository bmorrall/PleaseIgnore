module Logging
  # Removes invalid values from controller params
  class ControllerParamsFilter
    # Returns params with secure params removed
    def self.filter(params)
      params = params.reject do |param|
        param.starts_with?('_') ||
          param == ::ActionController::Base.request_forgery_protection_token.to_s
      end
      params.except!(*::ActionController::LogSubscriber::INTERNAL_PARAMS)

      filter_parameters = Rails.application.config.filter_parameters
      param_filter = ActionDispatch::Http::ParameterFilter.new(filter_parameters)
      param_filter.filter(params)
    end
  end
end
