require 'spec_helper'

describe "Contact" do
  enable_rails_cache

  def valid_create_attributes
    FactoryGirl.attributes_for(:contact)
  end

  describe "GET /contact" do
    context "as a visitor" do
      it "renders the contact page" do
        get contact_path
        expect(response.status).to be(200)
      end
      it 'notifies the user their previously visited url will be included' do
        get contact_path, nil, { 'HTTP_REFERER' => 'http://example.com/privacy' }
        assert_select '.alert.alert-info strong', 'Your message will mention you visited this page from http://example.com/privacy'
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get contact_path
        assert_select 'body.contacts.contacts-show'
      end
      it 'includes the page title' do
        get contact_path
        assert_select 'title', 'PleaseIgnore | Contact us'
      end
    end
  end

  describe 'POST /contact' do
    context 'as a visitor' do
      it 'redirects the user to a thank you page' do
        post contact_path(:contact => valid_create_attributes)
        expect(response).to redirect_to thank_you_contact_path
      end
      it 'notifies the user that their contact request was sent' do
        post contact_path(:contact => valid_create_attributes)
        follow_redirect!

        assert_select '.alert.alert-success strong', 'Your contact request has been sent'
      end
    end
  end

end
