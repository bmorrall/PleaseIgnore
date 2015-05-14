require 'rails_helper'

RSpec.describe 'Api::V1::Organisations', type: :request do
  def auth_params(email, token)
    { 'X-USER-EMAIL' => email, 'X-USER-TOKEN' => token }
  end

  describe 'GET index' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let(:authentication_token) { Devise.friendly_token }
      before(:each) do
        create(:authentication_token, user: user, body: authentication_token)
      end

      context 'with a an organisation' do
        let(:organisation) { create(:organisation) }
        before(:each) { user.add_role :owner, organisation }

        it 'should return a organisation collection' do
          get '/api/v1/organisations', nil, auth_params(user.email, authentication_token)
          expect(response).to be_success

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response.length).to eq 1

          organisation_json = json_response.first
          expect(organisation_json[:name]).to eq organisation.name
          expect(organisation_json[:url]).to eq api_v1_organisation_url(organisation)
          expect(organisation_json).to_not have_key :id
        end
      end
    end
  end

  describe 'GET show' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let(:authentication_token) { Devise.friendly_token }
      before(:each) do
        create(:authentication_token, user: user, body: authentication_token)
      end

      context 'with a an organisation' do
        let(:organisation) { create(:organisation) }
        before(:each) { user.add_role :owner, organisation }

        it 'should return a organisation collection' do
          get "/api/v1/organisations/#{organisation.permalink}",
              nil,
              auth_params(user.email, authentication_token)
          expect(response).to be_success

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response[:name]).to eq organisation.name
          expect(json_response[:url]).to eq api_v1_organisation_url(organisation)
          expect(json_response).to_not have_key :id
        end
      end
    end
  end
end
