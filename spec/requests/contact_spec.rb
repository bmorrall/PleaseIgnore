require 'rails_helper'

describe 'Contact', type: :request do
  enable_rails_cache

  def valid_create_attributes
    attributes_for(:contact)
  end

  describe 'GET /contact' do
    context 'as a visitor' do
      it 'renders the contact page' do
        get contact_path
        expect(response.status).to be(200)
      end
      it 'notifies the user their previously visited url will be included' do
        get contact_path, nil, 'HTTP_REFERER' => 'http://example.com/docs/privacy'
        assert_select '.alert.alert-info strong',
                      t('flash.contacts.show.info', referer: 'http://example.com/docs/privacy')
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get contact_path
        assert_select 'body.contacts.contacts-show'
      end
      it 'includes the page title' do
        get contact_path
        assert_select 'title', "#{application_name} | #{t 'contacts.show.page_title'}"
      end
    end
  end

  describe 'POST /contact AS xhr' do
    context 'as a visitor' do
      it 'redirects the user to a thank you page' do
        xhr :post, contact_path, contact: valid_create_attributes
        expect(response).to redirect_to thank_you_contact_path
      end
      it 'notifies the user that their contact request was sent' do
        xhr :post, contact_path, contact: valid_create_attributes
        follow_redirect!

        assert_select '.alert.alert-success strong', t('flash.contacts.create.notice')
      end
      it 'renders Turboboost errors for invalid request' do
        xhr :post, contact_path, contact: { name: 'Test User' }

        expect(response.status).to be(422)
        turboboost_errors = JSON.parse(response.body)
        expect(turboboost_errors['contact_email']).to include('Email can\'t be blank')
        expect(turboboost_errors['contact_body']).to include('Body can\'t be blank')
      end
    end
  end
end
