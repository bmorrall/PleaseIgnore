require 'spec_helper'

describe "devise/passwords/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
    end

    it "renders the new password reset request form" do
      render

      assert_select "form[action=?][method=?]", user_password_path, "post" do
        assert_select "input#user_email[name=?]", "user[email]"
      end
    end
  end

end
