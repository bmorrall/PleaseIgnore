class ContactsController < ApplicationController
  include Concerns::ControllerURIHelpers

  before_filter do
    authorize! :create, Contact
  end

  # GET /contact
  def show
    @contact = Contact.new
    if user_signed_in?
      @contact.name = current_user.name
      @contact.email = current_user.email
    end
    referer = request.headers['HTTP_X_XHR_REFERER'] || request.headers['HTTP_REFERER']
    @contact.referer = referer
    if referer && !current_page?(referer)
      flash.now[:info] = t('flash.contacts.show.info', referer: referer)
    end
    # show.html.haml
  end

  # POST /contact
  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      SupportMailer.contact_email(@contact.attributes).deliver
    end
    respond_with(@contact, action: :show, location: thank_you_contact_path)
  end

  # GET /contact/thank_you
  def thank_you
    # thank_you.html.haml
  end

end
