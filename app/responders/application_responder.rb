# Default Responder used by an Application
class ApplicationResponder < ActionController::Responder
  include Responders::FlashResponder
  include Responders::HttpCacheResponder
  require 'responders/turboboost_errors_responder'
  include Responders::TurboboostErrorsResponder
end
