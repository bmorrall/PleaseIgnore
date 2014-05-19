require 'app_responder'

class ApplicationController < ActionController::Base

  # Add common responders to Application
  self.responder = AppResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure CanCan(Can) authorizes all actions
  # check_authorization :unless => :devise_controller?

  # Add Parameters for Devise Controllers
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    raise exception
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:name, :terms_and_conditions]
    devise_parameter_sanitizer.for(:account_update) << :name
  end
end
