require 'rails_helper'

describe Api::V1::RegistrationsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post('/api/v1/registration')).to route_to('api/v1/registrations#create', format: :json)
    end
  end
end
