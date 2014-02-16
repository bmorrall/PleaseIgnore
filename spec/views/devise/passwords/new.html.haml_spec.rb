require 'spec_helper'

describe "devise/passwords/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      view.stub(:devise_mapping).and_return(Devise.mappings[:user])
      view.stub(:resource).and_return(user)
      view.stub(:resource_name).and_return('user')
    end

    it "renders the new password reset request form" do
      render

      assert_select "form[action=?][method=?]", user_password_path, "post" do
        assert_select "input#user_email[name=?]", "user[email]"
      end
    end
  end

end
