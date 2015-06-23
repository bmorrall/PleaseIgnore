require 'rails_helper'

RSpec.describe Security::HpkpReportsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/security/hpkp_report').to route_to('security/hpkp_reports#create')
    end
  end
end
