require 'spec_helper'

describe Users::SessionsController do
  describe 'routing' do

    it 'routes to #new' do
      expect(get('/users/sign_in')).to route_to('users/sessions#new')
    end

    it 'routes to #create' do
      expect(post('/users/sign_in')).to route_to('users/sessions#create')
    end

    it 'routes to #destroy' do
      expect(delete('/users/sign_out')).to route_to('users/sessions#destroy')
    end

  end
end
