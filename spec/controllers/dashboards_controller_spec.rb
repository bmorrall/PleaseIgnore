require 'rails_helper'

RSpec.describe DashboardsController, type: :controller do
  # GET /dashboard
  describe 'GET #show' do
    context 'as a signed in user' do
      login_user

      it 'renders the show page' do
        get :show
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(response).to render_with_layout(:dashboard)
      end
    end
    context 'as a visitor' do
      it 'redirects to the sign in page' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
