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

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response.keys).to eq([:authentication_token])

          token = json_response[:authentication_token]
          authentication_token = Tiddle::TokenIssuer.build.find_token(user, token)
          expect(authentication_token).to be_kind_of(AuthenticationToken)
        end
      end

      it 'renders a unuthorized JSON response when no matching user is found' do
        post api_v1_session_path, user: { email: 'test@example.com', password: 'wrong' }
        expect(response.status).to eq(401)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response).to eq(error: t('devise.failure.invalid'), status: 401)
      end

      it 'renders a unuthorized JSON response with an incorrect password' do
        user = create(:user, email: 'test@example.com')
        post api_v1_session_path, user: { email: user.email, password: 'wrong' }
        expect(response.status).to eq(401)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response).to eq(error: t('devise.failure.invalid'), status: 401)
      end

      describe 'Rate Limiting' do
        include ActiveSupport::Testing::TimeHelpers

        it 'rate limits requests to 5 attempts per 20 seconds from the same IP address' do
          travel_to(Time.now.midnight) do
            5.times do
              post api_v1_session_path
            end
            post api_v1_session_path
          end

          expect(response.status).to eq 429
          expect(response.body).to eq(
            { status: 429, error: I18n.t('rack_attack.limit_exceeded_message') }.to_json
          )
          expect(response.headers['Retry-After']).to eq 20
        end

        it 'rate limits requests to 5 attempts per 20 seconds with the same email address' do
          email = Faker::Internet.email
          travel_to(Time.now.midnight) do
            5.times do |i|
              post api_v1_session_path, { user: { email: email } }, 'REMOTE_ADDR' => "1.2.3.#{i}"
            end
            post api_v1_session_path, { user: { email: email } }, 'REMOTE_ADDR' => '1.2.3.6'
          end

          expect(response.status).to eq 429
          expect(response.body).to eq(
            { status: 429, error: I18n.t('rack_attack.limit_exceeded_message') }.to_json
          )
          expect(response.headers['Retry-After']).to eq 20
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let!(:authentication_token) { Tiddle.create_and_return_token(user, FakeRequest.new) }

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
