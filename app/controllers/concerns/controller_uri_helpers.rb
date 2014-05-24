
module Concerns
  # Allows Content For to be used in Controllers
  # Allows complex params to be set by controllers, and action caching without layout to work
  module ControllerURIHelpers
    extend ActiveSupport::Concern

    protected

    # rubocop:disable MethodLength
    def current_page?(options)
      unless request
        fail 'You cannot use helpers that need to determine the current ' \
             'page unless your view context provides a Request object ' \
             'in a #request method'
      end

      return false unless request.get? || request.head?

      url_string = URI.parser.unescape(url_for(options)).force_encoding(Encoding::BINARY)

      # We ignore any extra parameters in the request_uri if the
      # submitted url doesn't have any either. This lets the function
      # work with things like ?order=asc
      request_uri = url_string.index('?') ? request.fullpath : request.path
      request_uri = URI.parser.unescape(request_uri).force_encoding(Encoding::BINARY)

      if url_string =~ %r{^\w+://}
        url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
      else
        url_string == request_uri
      end
    end
    # rubocop:enable MethodLength
  end
end
