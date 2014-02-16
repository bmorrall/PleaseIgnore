require 'spec_helper'

describe "devise/registrations/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      view.stub(:devise_mapping).and_return(Devise.mappings[:user])
      view.stub(:resource).and_return(user)
      view.stub(:resource_name).and_return('user')
    end

    it "renders the new registration form" do
      render

      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_name[name=?]", "user[name]"
        assert_select "input#user_email[name=?]", "user[email]"
        assert_select "input#user_password[name=?]", "user[password]"
        assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
      end
    end
  end

end
