class ContactsController < ApplicationController
  include Concerns::BetterTurboboostErrors
  include Concerns::ControllerURIHelpers

  respond_to :html

  before_filter do
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
      SupportMailer.contact_email(@contact.attributes).deliver
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

  # Sets default values for contact based on current_user and refererr
  def update_contact_default_values(contact)
    # Preset User Detaisl
    if user_signed_in?
      contact.name = current_user.name
      contact.email = current_user.email
    end

    # Preset Referrer
    referer = request.headers['HTTP_X_XHR_REFERER'] || request.headers['HTTP_REFERER']
    contact.referer = referer
    if referer && !current_page?(referer)
      flash.now[:info] = t('flash.contacts.show.info', referer: referer)
    end
  end
end
