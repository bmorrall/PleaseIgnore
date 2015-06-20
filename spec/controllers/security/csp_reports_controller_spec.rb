require 'rails_helper'

RSpec.describe Security::CspReportsController, type: :controller do
  describe 'POST #create' do
    context 'with csp report' do
      let(:csp_report) do
        policy = "default-src 'none'; style-src cdn.example.com; report-uri /security/csp_report"
        {
          "csp-report": {
            "document-uri": 'http://example.com/signup.html',
            "referrer": '',
            "blocked-uri": 'http://example.com/css/style.css',
            "violated-directive": 'style-src cdn.example.com',
            "original-policy": policy
          }
        }
      end

      it 'sends a new CSP Report Email' do
        expect do
          post :create, csp_report: csp_report
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        subject = t('security.report_mailer.csp_report.subject')
        expect(ActionMailer::Base.deliveries.last.subject).to eq(
          "[#{application_name} TEST] #{subject}"
        )
      end

      it 'responds with success' do
        post :create, csp_report: csp_report

        expect(response).to be_success
        expect(response.body).to eq ''
      end
    end
  end
end
