require 'spec_helper'

describe 'contacts/show.html.haml' do

  context do # Within default nesting
    let(:contact) { Contact.new }

    it 'renders the change contact form' do
      assign(:contact, contact)
      render

      assert_select 'form[action=?][method=?]', contact_path, 'post' do
        assert_select 'input#contact_name[name=?]', 'contact[name]'
        assert_select 'input#contact_email[name=?]', 'contact[email]'
        assert_select 'textarea#contact_body[name=?]', 'contact[body]'
        assert_select 'input#contact_referer[name=?][type=?]', 'contact[referer]', 'hidden'
      end
    end
    describe 'autofocus fields' do
      it 'should autofocus on a blank name' do
        contact.name = ''
        contact.email = ''
        contact.body = ''
        assign(:contact, contact)
        render

        assert_select 'input#contact_name[autofocus]'
      end
      it 'should autofocus on a blank email' do
        contact.name = 'Test User'
        contact.email = ''
        contact.body = ''
        assign(:contact, contact)
        render

        assert_select 'input#contact_email[autofocus]'
      end
      it 'should autofocus on a blank body' do
        contact.name = 'Test User'
        contact.email = 'test@example.com'
        contact.body = ''
        assign(:contact, contact)
        render

        assert_select 'textarea#contact_body[autofocus]'
      end
    end
  end

end
