# Custom Rails Responders
module Responders
  # Renders AJAX errors as turboboost errors
  module TurboboostErrorsResponder
    # Attempts to render TurboBoost errors for a xhr (AJAX) response object containing errors,
    # otherwise falls back to the next item in the responder chain
    #
    def to_html
      if !get? && request.xhr? && has_errors?
        controller.render_turboboost_errors_for(resource)
      else
        defined?(super) ? super : to_format
      end
    end
  end
end
