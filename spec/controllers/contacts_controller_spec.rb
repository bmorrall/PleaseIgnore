require 'rails_helper'

describe ContactsController, type: :controller do

  def valid_create_attributes
    attributes_for(:contact)
  end

  describe 'GET show' do
    context 'as a vistor' do
      grant_ability :create, Contact

      context 'with a valid request' do
        before(:each) { get :show }
        it { is_expected.to render_template(:show) }
        it { is_expected.to render_with_layout('frontend') }
        it { expect(response.content_type).to eq('text/html') }
        it { is_expected.not_to set_flash }
        it { is_expected.not_to set_flash.now }
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
        it do
          is_expected.to set_flash.now[:info].to(
            t('flash.contacts.show.info', referer: 'http://pleaseignore.com/terms')
          )
        end
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
        it do
          is_expected.to set_flash.now[:info].to(
            t('flash.contacts.show.info', referer: 'http://pleaseignore.com/about')
          )
        end
      end
      context 'with a HTTP_REFERER header from the contact form' do
        before(:each) do
          request.headers['HTTP_REFERER'] = 'http://test.host/contact'
          get :show
        end
        it { is_expected.not_to set_flash.now }
      end
    end
    context 'as a logged in user' do
      login_user
      grant_ability :create, Contact

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
      grant_ability :create, Contact

      context 'with a valid xhr request' do
        before(:each) { xhr :post, :create, contact: valid_create_attributes }
        it { is_expected.to redirect_to thank_you_contact_path }
        it { is_expected.to set_flash[:notice].to t('flash.contacts.create.notice') }
        it 'should send a contact email to support' do
          email = ActionMailer::Base.deliveries.last
          expect(email.to).to eq(['support@pleaseignore.com'])
          expect(email.from).to eq(['contact@pleaseignore.com'])
          expect(email.subject).to end_with t('support_mailer.contact_email.subject')
          expect(email.subject).to start_with "[#{t('application.name')} TEST] "
        end
      end
      context 'with a xhr request with errors' do
        before(:each) { xhr :post, :create, contact: { name: 'not-valid' } }
        it { is_expected.to respond_with(:unprocessable_entity) }
        it { is_expected.not_to render_with_layout }
        it { is_expected.not_to set_flash }
        it 'should assign a contact with errors' do
          contact = assigns(:contact)
          expect(contact.errors).to_not be_empty
        end
        it 'should render valid JSON' do
          expect do
            JSON.parse(response.body)
          end.to_not raise_error
        end
      end

      it 'should send contact emails through a action mailer delivery job queue' do
        Sidekiq::Testing.fake! do
          mailer_worker = ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper
          expect do
            xhr :post, :create, contact: valid_create_attributes
          end.to change(mailer_worker.jobs, :size).by(1)

          mailer_job = mailer_worker.jobs.last
          expect(mailer_job['queue']).to eq('mailer')
        end
      end
      it 'should not send any emails with an invalid request' do
        expect do
          xhr :post, :create, contact: { name: 'not-valid' }
        end.to_not change(ActionMailer::Base.deliveries, :count)
      end
    end
  end

  describe 'GET thank_you' do
    grant_ability :create, Contact

    context 'as a visitor' do
      context 'with a valid request' do
        before(:each) { get :thank_you }
        it { is_expected.to render_template(:thank_you) }
        it { is_expected.to render_with_layout('frontend') }
        it { is_expected.not_to set_flash }
      end
    end
  end

end
