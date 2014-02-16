require 'spec_helper'

describe "devise/sessions/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      view.stub(:devise_mapping).and_return(Devise.mappings[:user])
      view.stub(:resource).and_return(user)
      view.stub(:resource_name).and_return('user')
    end

    it "renders the new session form" do
      render

      assert_select "form[action=?][method=?]", user_session_path, "post" do
        assert_select "input#user_email[name=?]", "user[email]"
        assert_select "input#user_password[name=?]", "user[password]"
      end
    end

    it "renders the social media login buttons" do
      render

      assert_select "a.btn-facebook[href=?]", '/auth/facebook'
      assert_select "a.btn-google-plus[href=?]", '/auth/google'
      assert_select "a.btn-github[href=?]", '/auth/github'
      assert_select "a.btn-twitter[href=?]", '/auth/twitter'
    end

    it "renders a create account link" do
      render

      assert_select "a[href=?]", new_user_registration_path
    end

    it "renders a password reset link" do
      render

      assert_select "a[href=?]", new_user_password_path
    end
  end

end
