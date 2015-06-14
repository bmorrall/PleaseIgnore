require 'rails_helper'

RSpec.describe 'Api::V1::Organisations', type: :request do
  def auth_params(email, token)
    { 'X-USER-EMAIL' => email, 'X-USER-TOKEN' => token }
  end

  describe 'GET index' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let!(:authentication_token) { Tiddle.create_and_return_token(user, FakeRequest.new) }

      context 'with a an organisation' do
        let(:organisation) { create(:organisation) }
        before(:each) { user.add_role :owner, organisation }

        it 'should return a organisation collection' do
          get '/api/v1/organisations', nil, auth_params(user.email, authentication_token)
          expect(response).to be_success

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response.length).to eq 1

          organisation_json = json_response.first
          expect(organisation_json[:id]).to eq organisation.permalink
          expect(organisation_json[:name]).to eq organisation.name
          expect(organisation_json[:url]).to eq api_v1_organisation_url(organisation)
        end
      end
    end
  end

  describe 'GET show' do
    context 'as a signed in user' do
      let(:user) { create :user }
      let!(:authentication_token) { Tiddle.create_and_return_token(user, FakeRequest.new) }

      context 'with a an organisation' do
        let(:organisation) { create(:organisation) }
        before(:each) { user.add_role :owner, organisation }

        it 'should return a organisation collection' do
          get "/api/v1/organisations/#{organisation.permalink}",
              nil,
              auth_params(user.email, authentication_token)
          expect(response).to be_success

          json_response = JSON.parse(response.body, symbolize_names: true)
          expect(json_response[:id]).to eq organisation.permalink
          expect(json_response[:name]).to eq organisation.name
          expect(json_response[:url]).to eq api_v1_organisation_url(organisation)
        end
      end
    end
  end
end
