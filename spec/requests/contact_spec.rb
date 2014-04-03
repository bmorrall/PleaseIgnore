require 'spec_helper'

describe "Contact" do
  enable_rails_cache

  describe "GET /contact" do
    context "as a visitor" do
      it "renders the contact page" do
        get contact_path
        expect(response.status).to be(200)
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

end
