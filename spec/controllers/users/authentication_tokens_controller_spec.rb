require 'rails_helper'

RSpec.describe Users::AuthenticationTokensController, type: :controller do

  describe 'GET #index' do
    context 'with a signed in User' do
      login_user
      grant_ability :read, AuthenticationToken

      it 'assigns all users_authentication_tokens as @users_authentication_tokens' do
        authentication_token = create(:authentication_token, user: logged_in_user)
        get :index, {}
        expect(assigns(:authentication_tokens)).to eq([authentication_token])
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with a signed in User' do
      login_user
      grant_ability :destroy, AuthenticationToken

      it 'destroys the requested users_authentication_token' do
        authentication_token = create(:authentication_token, user: logged_in_user)
        expect do
          delete :destroy, id: authentication_token.to_param
        end.to change(AuthenticationToken, :count).by(-1)
      end

      it 'redirects to the users_authentication_tokens list' do
        authentication_token = create(:authentication_token, user: logged_in_user)
        delete :destroy, id: authentication_token.to_param
        expect(response).to redirect_to(users_authentication_tokens_url)
      end
    end
  end
end
