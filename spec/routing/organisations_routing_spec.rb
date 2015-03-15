require 'rails_helper'

RSpec.describe OrganisationsController, type: :routing do
  describe 'routing' do

    it 'routes to #show' do
      expect(get: '/organisations/1').to route_to('organisations#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/organisations/1/edit').to route_to('organisations#edit', id: '1')
    end

    it 'routes to #update' do
      expect(put: '/organisations/1').to route_to('organisations#update', id: '1')
    end
  end
end
