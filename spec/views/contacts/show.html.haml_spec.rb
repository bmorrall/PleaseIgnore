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
  end

end
