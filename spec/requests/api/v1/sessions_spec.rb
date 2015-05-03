require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  def auth_params(email, token)
    { 'X-USER-EMAIL' => email, 'X-USER-TOKEN' => token }
  end

  describe 'POST create' do
    context 'as a visitor' do
      context 'with a successful login attempt' do
        let!(:user) { create(:user) }

        it 'creates a new AuthenticationToken' do
          expect do
            post api_v1_session_path, user: { email: user.email, password: user.password }
          end.to change(AuthenticationToken, :count).by(1)
        end

        it 'returns a JSON response with the authentication token' do
          post api_v1_session_path, user: { email: user.email, password: user.password }
          expect(response).to be_success

          authentication_token = user.authentication_tokens.first.body
          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response).to eq(authentication_token: authentication_token)
        end
      end

      it 'renders a unuthorized JSON response when no matching user is found' do
        post api_v1_session_path, user: { email: 'test@example.com', password: 'wrong' }
        expect(response.status).to eq(401)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response).to eq(error: t('devise.failure.invalid'), status: 401)
      end

      it 'renders a unuthorized JSON response with an incorrect password' do
        create :user, email: 'test@example.com'
        post api_v1_session_path, user: { email: 'test@example.com', password: 'wrong' }
        expect(response.status).to eq(401)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response).to eq(error: t('devise.failure.invalid'), status: 401)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let(:authentication_token) { Devise.friendly_token }
      before(:each) do
        create(:authentication_token, user: user, body: authentication_token)
      end

      context 'with a successful request' do
        it 'deletes the AuthenticationToken from the user' do
          expect do
            delete api_v1_session_path, nil, auth_params(user.email, authentication_token)
          end.to change(user.authentication_tokens, :count).by(-1)
        end

        it 'should return a JSON success response' do
          delete api_v1_session_path, nil, auth_params(user.email, authentication_token)
          expect(response).to be_success

          json_response = JSON.parse(response.body)
          expect(json_response).to eq({})
        end
      end
    end

    it 'should return a successful response with a incorrect authentication token' do
      user = create(:user)
      delete api_v1_session_path, nil, auth_params(user.email, 'not-correct')
      expect(response).to be_success

      json_response = JSON.parse(response.body)
      expect(json_response).to eq({})
    end

    it 'should return a successful response with a unknown email address' do
      delete api_v1_session_path, nil, auth_params(Faker::Internet.email, 'not-correct')
      expect(response).to be_success

      json_response = JSON.parse(response.body)
      expect(json_response).to eq({})
    end
  end
end
