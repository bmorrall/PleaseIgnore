require 'rails_helper'

describe 'Security::CSPReport', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe 'POST /security/csp_report' do
    it 'sends a CSP Report email' do
      expect do
        policy = "default-src 'none'; style-src cdn.example.com; report-uri /security/csp_report"
        post '/security/csp_report', {
          "csp-report": {
            "document-uri": 'http://example.com/signup.html',
            "referrer": '',
            "blocked-uri": 'http://example.com/css/style.css',
            "violated-directive": 'style-src cdn.example.com',
            "original-policy": policy
          }
        }.to_json, 'CONTENT_TYPE' => 'application/csp-report'
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      subject = I18n.t('security.report_mailer.csp_report.subject')
      expect(ActionMailer::Base.deliveries.last.to).to eq(['security@example.com'])
      expect(ActionMailer::Base.deliveries.last.subject).to eq(subject)
    end

    describe 'Rake::Attack limiting' do
      it 'limits requests to 5 a minute' do
        travel_to 1.minute.ago do
          # Run the allowed number of requests
          5.times { post('/security/csp_report') }
          expect(response.status).to_not eq(429)

          # Run the forbidden request
          post('/security/csp_report')
          expect(response.status).to be(429)
          expect(response.headers['Retry-After']).to eq(60)
          expect(response.body).to eq(
            {
              status: 429,
              error: I18n.t('security.rack_attack.limit_exceeded_message')
            }.to_json
          )
        end

        # Verify the limit has passed
        post('/security/csp_report')
        expect(response.status).to_not be(429)
      end
    end
  end
end
