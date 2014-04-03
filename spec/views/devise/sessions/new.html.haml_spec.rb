require 'spec_helper'

describe "devise/sessions/new.html.haml" do

  context do # Within default nesting
    let(:user) { User.new }
    before(:each) do
      allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])
      allow(view).to receive(:resource).and_return(user)
      allow(view).to receive(:resource_name).and_return('user')
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

      assert_select "a.btn-facebook[href=?][rel='nofollow']", '/users/auth/facebook'
      assert_select "a.btn-google-plus[href=?][rel='nofollow']", '/users/auth/google_oauth2'
      assert_select "a.btn-github[href=?][rel='nofollow']", '/users/auth/github'
      assert_select "a.btn-twitter[href=?][rel='nofollow']", '/users/auth/twitter'
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
