require 'rails_helper'

describe 'SecureHeaders' do
  describe 'GET /' do
    context 'as a visitor' do
      it 'adds HTTP Secure Headers' do
        get root_url

        expect(response.headers['X-Frame-Options']).to eq('DENY')
        expect(response.headers['X-XSS-Protection']).to eq('1; mode=block')
        expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
        expect(response.headers['X-Download-Options']).to eq('noopen')
        expect(response.headers['X-Permitted-Cross-Domain-Policies']).to eq('none')
      end
    end
  end
end
