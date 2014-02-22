class ContactsController < ApplicationController
  include ActionView::Helpers::UrlHelper

  def show
    @contact = Contact.new
    referer = request.headers['HTTP_X_XHR_REFERER'] || request.headers['HTTP_REFERER']
    @contact.referer = referer
    if referer && !current_page?(referer)
      flash.now[:info] = "Your message will mention you visited this page from #{referer}"
    end
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.valid?
      SupportMailer.contact_email(@contact.attributes).deliver
      flash[:notice] = 'Your contact request has been sent'
      redirect_to thank_you_contact_path
    else
      render :show
    end
  end

end