require 'rails_helper'

describe 'Security::CSPReport', type: :request do
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

      subject = t('security.report_mailer.csp_report.subject')
      expect(ActionMailer::Base.deliveries.last.subject).to eq(
        "[#{application_name} TEST] #{subject}"
      )
    end
  end
end
