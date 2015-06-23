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

      context 'when the logged in user has changed their name' do
        before(:each) do
          with_versioning { logged_in_user.update_attribute :name, Faker::Name.name }
        end

        it 'renders a profile updated version' do
          get users_versions_path
          assert_select '.versions-list h4', I18n.t('decorators.versions.title.profile.update')
          assert_select '.versions-list .change-summary'
        end
      end

      context 'when the logged in user has confirmed their account' do
        before(:each) do
          with_versioning { logged_in_user.confirm }
        end

        it 'renders a user confirmed version' do
          get users_versions_path
          assert_select '.versions-list h4', I18n.t('decorators.versions.title.user.confirmed')
          assert_select '.versions-list .change-summary', false
        end
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
