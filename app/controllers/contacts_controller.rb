# Contacts Controller
# Allows Visitors and Users to send Contact requests to Support
#
# - Prepopulates Contact if the current user is signed in
# - Keeps track of the Referring page to assist support
#
class ContactsController < ApplicationController
  include Concerns::BetterTurboboostErrors
  include ActionView::Helpers::UrlHelper

  layout 'frontend'

  respond_to :html

  before_action do
    authorize! :create, Contact
  end

  # Displays a Contact Form for making a support request
  #
  # @api public
  # @example GET /contact
  # @return void
  def show
    @contact = Contact.new
    update_contact_default_values @contact
    respond_with(@contact)
  end

  # Processes a Contact form and sends a request to support
  #
  # @api public
  # @example POST /contact
  # @return void
  def create
    @contact = Contact.new(contact_params)
    if @contact.valid?
      # Send the contact mail
      ContactMailer.support_email(@contact.attributes).deliver_later(queue: Workers::MAILERS)
    end
    respond_with(@contact, action: :show, location: thank_you_contact_path)
  end

  # Displays a thank you message to the user for finishing the contact form
  #
  # @api public
  # @example GET /contact/thank_you
  # @return void
  def thank_you
    # thank_you.html.haml
  end

  protected

  # Strong parameters for Contact
  # @api private
  # @return [Hash] Sanitised params for creating a {Contact}
  def contact_params
    allowed_params = [:body, :referer]
    allowed_params << [:name, :email] unless user_signed_in?
    params.require(:contact).permit(allowed_params).merge(contact_params_from_request)
  end

  # @api private
  # @return [Strings] The url previously visited when displaying the contact form
  def http_referer
    @http_referer ||= request.headers['HTTP_X_XHR_REFERER'] || request.headers['HTTP_REFERER']
  end

  # Adds the user agent, and name and email if the user is signed in
  def contact_params_from_request
    { user_agent: request.user_agent }.tap do |extra_params|
      extra_params.merge!(name: current_user.name, email: current_user.email) if user_signed_in?
    end
  end

  # Sets default values for contact based on current_user and refererr
  #
  # @api private
  # @param contact [Contact] Contact to be updated based
  # @return void
  def update_contact_default_values(contact)
    contact.user = current_user if user_signed_in? # Preset User Details
    contact.referer = http_referer # Preset Referrer

    display_referer_flash_message(http_referer)
  end

  # Displays a flash message showing the page the user was previously at
  #
  # @api private
  # @return void
  def display_referer_flash_message(referer)
    return if !referer || current_page?(referer)
    flash.now[:info] = t('flash.contacts.show.info', referer: referer)
  end
end
