require 'rails_helper'

RSpec.describe 'Api::V1::Registrations', type: :request do
  describe 'POST create' do
    def valid_user_attributes
      attributes_for(:user)
    end

    def invalid_user_attributes
      { email: 'not-valid' }
    end

    context 'as a visitor' do
      context 'with a successful request' do
        it 'creates a new User' do
          expect do
            post api_v1_registration_path, user: valid_user_attributes
          end.to change(User, :count).by(1)
        end

        it 'returns a JSON response with the authentication token' do
          post api_v1_registration_path, user: valid_user_attributes
          expect(response).to be_success

          authentication_token = AuthenticationToken.first.body
          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response).to eq(authentication_token: authentication_token)
        end
      end

      it 'renders a unauthorized JSON response when the User account is inactive' do
        # TODO: Create Inactive User
        allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
        allow_any_instance_of(User).to receive(:inactive_message).and_return('inactive')

        post api_v1_registration_path, user: valid_user_attributes
        expect(response.status).to eq(401)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response).to eq(
          error: t('devise.registrations.signed_up_but_inactive'), status: 401
        )
      end

      it 'renders a unproccessable entity JSON response when provided with invalid parameters' do
        post api_v1_registration_path, user: invalid_user_attributes
        expect(response.status).to eq(422)

        json_response = JSON.parse(response.body, symbolize_names: true)
        expect(json_response[:status]).to eq(422)
        expect(json_response[:errors]).to be_a_kind_of(Hash)
      end
    end
  end
end
