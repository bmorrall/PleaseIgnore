require 'rails_helper'

describe 'contacts/show.html.haml', type: :view do

  context 'with a new Contact' do
    let(:contact) { Contact.new }
    before(:each) { assign(:contact, contact) }

    describe 'the change contact form' do
      it 'renders the form' do
        render

        assert_select 'form[action=?][method=?]', contact_path, 'post' do
          assert_select 'input#contact_name[name=?]', 'contact[name]'
          assert_select 'input#contact_email[name=?]', 'contact[email]'
          assert_select 'textarea#contact_body[name=?]', 'contact[body]'
          assert_select 'input#contact_referer[name=?][type=?]', 'contact[referer]', 'hidden'
        end
      end
      it 'renders all form labels' do
        render

        assert_select 'label[for=?]', 'contact_name', 'Name'
        assert_select 'label[for=?]', 'contact_email', 'Email'
        assert_select 'label[for=?]', 'contact_body', 'Body'
      end
      it 'renders all form placeholders' do
        render

        assert_select '#contact_name[placeholder=?]',
                      t('simple_form.placeholders.defaults.name')
        assert_select '#contact_email[placeholder=?]',
                      t('simple_form.placeholders.defaults.email')
        assert_select '#contact_body[placeholder=?]',
                      t('simple_form.placeholders.defaults.body')
      end
    end

    describe 'autofocus fields' do
      it 'should autofocus on a blank name' do
        contact.name = ''
        contact.email = ''
        contact.body = ''
        render

        assert_select 'input#contact_name[autofocus]'
      end
      it 'should autofocus on a blank email' do
        contact.name = 'Test User'
        contact.email = ''
        contact.body = ''
        render

        assert_select 'input#contact_email[autofocus]'
      end
      it 'should autofocus on a blank body' do
        contact.name = 'Test User'
        contact.email = 'test@example.com'
        contact.body = ''
        render

        assert_select 'textarea#contact_body[autofocus]'
      end
    end
  end

end
