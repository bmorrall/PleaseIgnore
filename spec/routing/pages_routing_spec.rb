require 'rails_helper'

describe PagesController, type: :routing do
  describe 'routing' do
    it 'routes root to #show' do
      expect(get('/')).to route_to('pages#show', id: 'home')
    end

    %w(styles privacy terms).each do |page|
      it "routes /docs/#{page} to #show" do
        expect(get("/docs/#{page}")).to route_to('pages#show', id: page)
      end
    end
  end
end
