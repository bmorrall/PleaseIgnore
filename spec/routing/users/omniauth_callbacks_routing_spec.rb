require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :routing do
  describe 'routing' do

    it 'routes to #facebook callback' do
      expect(post('/users/auth/facebook/callback')).to route_to('users/omniauth_callbacks#facebook')
    end

    it 'routes to #twitter callback' do
      expect(post('/users/auth/twitter/callback')).to route_to('users/omniauth_callbacks#twitter')
    end

    it 'routes to #github callback' do
      expect(post('/users/auth/github/callback')).to route_to('users/omniauth_callbacks#github')
    end

    it 'routes to #google_oauth2 callback' do
      expect(post('/users/auth/google_oauth2/callback')).to(
        route_to('users/omniauth_callbacks#google_oauth2')
      )
    end

  end
end
