# Contacts Controller
# Allows Visitors and Users to send Contact requests to Support
#
# - Prepopulates Contact if the current user is signed in
# - Keeps track of the Referring page to assist support
#
class ContactsController < ApplicationController
  include Concerns::BetterTurboboostErrors
  include ActionView::Helpers::UrlHelper

  respond_to :html

  before_action do
    authorize! :create, Contact
  end

  # GET /contact
  def show
    @contact = Contact.new
    update_contact_default_values @contact
    respond_with(@contact)
  end

  # POST /contact
  def create
    @contact = Contact.new(contact_params)
    if @contact.valid?
      # Send the contact mail
      SupportMailer.contact_email(@contact.attributes).deliver_later(queue: :mailer)
    end
    respond_with(@contact, action: :show, location: thank_you_contact_path)
  end

  # GET /contact/thank_you
  def thank_you
    # thank_you.html.haml
  end

  protected

  # Strong parameters for Contact
  def contact_params
    params.require(:contact).permit(:name, :email, :body, :referer)
  end

  def http_referer
    @http_referer ||= request.headers['HTTP_X_XHR_REFERER'] || request.headers['HTTP_REFERER']
  end

  # Sets default values for contact based on current_user and refererr
  #
  # @param contact [Contact] Contact to be updated based
  def update_contact_default_values(contact)
    contact.user = current_user if user_signed_in? # Preset User Details
    contact.referer = http_referer # Preset Referrer

    display_referer_flash_message(http_referer)
  end

  def display_referer_flash_message(referer)
    return if !referer || current_page?(referer)
    flash.now[:info] = t('flash.contacts.show.info', referer: referer)
  end
end
