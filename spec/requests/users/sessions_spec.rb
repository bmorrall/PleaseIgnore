require 'spec_helper'

describe "Sessions" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_session_path
        expect(response.status).to be(200)
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

  describe 'POST create' do
    context 'as a visitor' do
      context 'with a failed login attempt' do
        before(:each) do
          post user_session_path, { user: { email: 'test@example.com', password: 'wrong' }}
        end

        it 'displays a generic alert to the user' do
          assert_select '.alert-danger strong', 'Invalid email or password.'
        end
      end
    end
  end

end
