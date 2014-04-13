require 'spec_helper'

describe ContactsController do

  def valid_create_attributes
    FactoryGirl.attributes_for(:contact)
  end

  describe 'GET show' do
    context 'as a vistor' do
      context 'with a valid request' do
        before(:each) { get :show }
        it { should render_template(:show) }
        it { should render_with_layout(:application) }
        it { expect(response.content_type).to eq('text/html') }
        it { should_not set_the_flash }
        it { should_not set_the_flash.now }
        it 'assigns a Contact to contact' do
          expect(assigns(:contact)).to be_kind_of(Contact)
        end
      end
      context 'with a request containg a HTTP_REFERER header' do
        before(:each) do
          request.headers['HTTP_REFERER'] = 'http://pleaseignore.com/terms'
          get :show
        end
        it 'should set the contact referrer' do
         contact = assigns(:contact)
         expect(contact.referer).to eq('http://pleaseignore.com/terms')
        end
        it { should set_the_flash.now[:info].to 'Your message will mention you visited this page from http://pleaseignore.com/terms' }
      end
      context 'with a request containg a HTTP_X_XHR_REFERER header' do
        before(:each) do
          request.headers['HTTP_X_XHR_REFERER'] = 'http://pleaseignore.com/about'
          get :show
        end
        it 'should set the contact referrer' do
         contact = assigns(:contact)
         expect(contact.referer).to eq('http://pleaseignore.com/about')
        end
        it { should set_the_flash.now[:info].to 'Your message will mention you visited this page from http://pleaseignore.com/about' }
      end
      context 'with a HTTP_REFERER header from the contact form' do
        before(:each) do
          request.headers['HTTP_REFERER'] = 'http://test.host/contact'
          get :show
        end
        it { should_not set_the_flash.now }
      end
    end
    context 'as a logged in user' do
      login_user
      context 'with a valid request' do
        before(:each) { get :show }
        it 'should set the contact name' do
          contact = assigns(:contact)
          expect(contact.name).to eq(logged_in_user.name)
        end
        it 'should set the contact email' do
          contact = assigns(:contact)
          expect(contact.email).to eq(logged_in_user.email)
        end
      end
    end
  end

  describe 'POST create' do
    context 'as a visitor' do
      context 'with a valid request' do
        before(:each) { post :create, :contact => valid_create_attributes }
        it { should redirect_to thank_you_contact_path }
        it { should set_the_flash[:notice].to 'Your contact request has been sent' }
        it 'should send a contact email to support' do
          email = ActionMailer::Base.deliveries.last
          expect(email.to).to eq(['support@pleaseignore.com'])
          expect(email.from).to eq(['contact@pleaseignore.com'])
          expect(email.subject).to eq('PleaseIgnore Contact Email')
        end
      end
      context 'with a invalid request' do
        before(:each) { post :create, :contact => [] }
        it { should render_template(:show) }
        it { should render_with_layout(:application) }
        it { should_not set_the_flash }
        it 'should assign a contact with errors' do
          contact = assigns(:contact)
          expect(contact.errors).to_not be_empty
        end
      end
      it 'should not send any emails with an invalid request' do
        expect { post :create, :contact => [] }.to_not change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  describe 'GET thank_you' do
    context 'as a visitor' do
      context 'with a valid request' do
        before(:each) { get :thank_you }
        it { should render_template(:thank_you) }
        it { should render_with_layout(:application) }
        it { should_not set_the_flash }
      end
    end
  end

end