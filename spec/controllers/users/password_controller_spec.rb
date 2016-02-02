require 'rails_helper'

RSpec.describe Users::PasswordController, type: :controller do
  describe 'GET #index' do
    it { should route(:get, '/users/password').to(action: :index) }

    context 'with a signed in User' do
      login_user

      it 'should render the index template' do
        get :index
        expect(response).to be_success
        expect(response).to render_template(:index)
        expect(response).to render_with_layout(:dashboard_backend)
      end
    end
    context 'as a visitor' do
      it 'redirects to the sign in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
        should set_flash[:alert].to t('devise.failure.unauthenticated')
      end
    end
  end
end
