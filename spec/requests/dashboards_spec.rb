require 'rails_helper'

describe 'Dashboard', type: :request do
  enable_rails_cache

  describe 'GET /dashboard' do
    context 'as a user' do
      login_user

      it 'renders the contact page' do
        get dashboard_path
        expect(response.status).to be(200)
      end

      context 'as an unconfirmed user' do
        it 'renders the dashboard/confirmation cell' do
          get dashboard_path
          assert_select '.confirm-account'
        end
      end

      describe 'Metadata' do
        it 'renders all expected metadata' do
          get dashboard_path
          assert_select 'body.dashboards.dashboards-show'
          assert_select 'title', "#{application_name} | #{t('dashboards.show.page_title')}"
        end
      end
    end
  end
end
