require 'spec_helper'

RSpec.describe Security::CspReportsController, type: :controller do
  routes { Security::Engine.routes }

  it { should route(:post, 'csp_report').to(controller: 'security/csp_reports', action: 'create') }

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
        }.to_json
      end

      it 'sends a new CSP Report Email', :queue_workers do
        expect do
          post :create, csp_report
        end.to enqueue_a_mailer(Security::ReportMailer, :csp_report, queue: Workers::HIGH_PRIORITY)
      end

      it 'responds with success' do
        post :create, csp_report

        expect(response).to be_success
        expect(response.body).to eq ''
      end
    end

    it 'handles malformed csp report requests' do
      expect(Logging).to receive(:log_error).with(kind_of(JSON::ParserError))
      expect do
        post :create, 'totally, not valid json]'
      end.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
