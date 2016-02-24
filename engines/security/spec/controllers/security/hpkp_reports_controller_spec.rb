require 'spec_helper'

RSpec.describe Security::HpkpReportsController, type: :controller do
  routes { Security::Engine.routes }

  it do
    should route(:post, 'hpkp_report').to(controller: 'security/hpkp_reports', action: 'create')
  end

  describe 'POST #create' do
    context 'with hpkp report' do
      let(:hpkp_report) do
        {
          "date-time": DateTime.now.rfc3339,
          "hostname": 'example.com',
          "port": '80',
          "effective-expiration-date": DateTime.now.rfc3339,
          "include-subdomains": false,
          "noted-hostname": 'example.com',
          "served-certificate-chain": [],
          "validated-certificate-chain": [],
          "known-pins": []
        }.to_json
      end

      it 'sends a new HPKP Report Email', :queue_workers do
        expect do
          post :create, hpkp_report
        end.to enqueue_a_mailer(Security::ReportMailer, :hpkp_report, queue: Workers::HIGH_PRIORITY)
      end

      it 'responds with success' do
        post :create, hpkp_report

        expect(response).to be_success
        expect(response.body).to eq ''
      end
    end
  end
end
