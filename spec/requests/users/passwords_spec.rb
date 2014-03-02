require 'spec_helper'

describe "Passwords" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_password_path
        response.status.should be(200)
      end
    end
    describe 'Metadata' do
      it "includes the body class" do
        get new_user_password_path
        assert_select 'body.users-passwords.users-passwords-new'
      end
      it "includes the page title" do
        get new_user_password_path
        assert_select 'title', 'PleaseIgnore | Forgot your password?'
      end
    end
  end

end