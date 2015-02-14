require 'rails_helper'

describe 'Users/Versions', type: :request do

  describe 'GET index' do
    context 'as a admin' do
      login_user
      before(:each) { logged_in_user.add_role :admin }

      it 'renders the index page' do
        get users_versions_path
        expect(response.status).to be(200)
      end

      describe 'Metadata' do
        it 'includes the body class' do
          get users_versions_path
          assert_select 'body.users-versions.users-versions-index'
        end
        it 'includes the page title' do
          get users_versions_path
          assert_select 'title', "#{application_name} | #{t 'users.versions.index.page_title'}"
        end
      end
    end
  end

end
