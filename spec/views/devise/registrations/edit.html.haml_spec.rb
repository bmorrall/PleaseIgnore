require 'spec_helper'

describe "devise/registrations/edit.html.haml" do

  context do # Within default nesting
    let(:user) { FactoryGirl.build_stubbed(:user) }
    let(:display_profile) { true }
    let(:display_password_change) { true }
    let(:display_accounts) { true }

    before(:each) do
      view.stub(:devise_mapping).and_return(Devise.mappings[:user])
      view.stub(:resource).and_return(user)
      view.stub(:resource_name).and_return('user')

      view.stub(:display_profile?).and_return(display_profile)
      view.stub(:display_password_change?).and_return(display_password_change)
      view.stub(:display_accounts?).and_return(display_accounts)
    end

    it "renders the update profile form" do
      render

      assert_select "h3", 'Profile Information'
      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_name[name=?]", "user[name]"
        assert_select "input#user_email[name=?]", "user[email]"
      end
    end

    it "renders the change password form" do
      render

      assert_select "h3", 'Change Password'
      assert_select "form[action=?][method=?]", user_registration_path, "post" do
        assert_select "input#user_password[name=?]", "user[password]"
        assert_select "input#user_password_confirmation[name=?]", "user[password_confirmation]"
        assert_select "input#user_current_password[name=?]", "user[current_password]"
      end
    end
  end

end
