require 'rails_helper'

describe 'Users/Histories', type: :request do
  describe 'GET show' do
    context 'as a user' do
      login_user

      it 'renders the index page' do
        get users_history_path
        expect(response.status).to be(200)
      end

      context 'when the logged in user has changed their name' do
        before(:each) do
          with_versioning { put user_registration_path, user: { name: Faker::Name.name } }
        end

        it 'renders a profile updated version' do
          get users_history_path
          assert_select '.versions-list h4', I18n.t('decorators.versions.title.profile.update')
          assert_select '.versions-list .change-summary', count: 0
        end
      end

      describe 'Metadata' do
        it 'includes the body class' do
          get users_history_path
          assert_select 'body.users-histories.users-histories-show'
        end
        it 'includes the page title' do
          get users_history_path
          assert_select 'title', "#{application_name} | #{t 'users.histories.show.page_title'}"
        end
      end
    end
  end
end
