# Base Application Controller
#
# - Enables CSRF Protection with exception throwing.
# - Filters extra params for Devise (name)
#
class ApplicationController < ActionController::Base
  # Add common responders to Application
  self.responder = ApplicationResponder

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure CanCan(Can) authorizes all actions
  # check_authorization :unless => :devise_controller?

  # Add extra parameters for Devise Controllers
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    fail exception
  end

  # [Devise] Redirects signed in users to their profile instead of root
  def after_sign_in_path_for(resource)
    default_url = edit_user_registration_path
    stored_path = request.env['omniauth.origin'] || stored_location_for(resource)
    case stored_path.try(:gsub, root_url, '/')
    when root_path
      # Don't return to homepage
      default_url
    when %r{\A/users/}
      # Don't return to sign in/up page
      default_url
    else
      stored_path
    end || default_url
  end

  # [Devise] Adds extra User params to Devise param sanitiser
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :terms_and_conditions]
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  # [PaperTrail] include IP and User Agent in version history
  def info_for_paper_trail
    {
      comments: params[:comments],
      ip: request.remote_ip,
      user_agent: request.user_agent
    }
  end
end
