require 'rails_helper'

RSpec.describe Security::CspReportsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/security/csp_report').to route_to('security/csp_reports#create')
    end
  end
end
