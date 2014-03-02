require 'spec_helper'

describe "Sessions" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_session_path
        response.status.should be(200)
      end
    end
    describe 'Metadata' do
      it "includes the body class" do
        get new_user_session_path
        assert_select 'body.users-sessions.users-sessions-new'
      end
      it "includes the page title" do
        get new_user_session_path
        assert_select 'title', 'PleaseIgnore | Login'
      end
    end
  end

end
