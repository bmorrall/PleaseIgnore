module Responders
  # Renders AJAX errors as turboboost errors
  module TurboboostErrorsResponder
    def to_html
      if !get? && request.xhr? && has_errors?
        controller.render_turboboost_errors_for(resource)
      else
        defined?(super) ? super : to_format
      end
    end

    def to_js
      if !get? && has_errors?
        controller.render_turboboost_errors_for(resource)
      else
        defined?(super) ? super : to_format
      end
    end
  end
end
