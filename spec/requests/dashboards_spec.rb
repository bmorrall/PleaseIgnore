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
      it 'renders the dashboard/empty cell' do
        get dashboard_path
        assert_select 'p', t('dashboard.empty.display.empty_message')
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
