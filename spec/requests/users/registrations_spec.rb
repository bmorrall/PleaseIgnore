require 'spec_helper'

describe "Registrations" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_registration_path
        response.status.should be(200)
      end
    end
    describe 'Metadata' do
      it "includes the body class" do
        get new_user_registration_path
        assert_select 'body.users-registrations.users-registrations-new'
      end
      it "includes the page title" do
        get new_user_registration_path
        assert_select 'title', 'PleaseIgnore | Create Account'
      end
    end
  end

end
