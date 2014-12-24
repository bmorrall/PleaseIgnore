require 'rails_helper'

describe Users::AccountsController, type: :routing do
  describe 'routing' do

    it 'routes to #destroy' do
      expect(delete('/users/accounts/1')).to route_to('users/accounts#destroy', id: '1')
    end

    it 'routes to #sort' do
      expect(post('/users/accounts/sort')).to route_to('users/accounts#sort')
    end

  end
end
