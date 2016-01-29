require 'rails_helper'

RSpec.describe Security::HpkpReportsController, type: :controller do
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
        }
      end

      it 'sends a new HPKP Report Email' do
        expect do
          post :create, hpkp_report
        end.to change(ActionMailer::Base.deliveries, :count).by(1)

        subject = t('security.report_mailer.hpkp_report.subject')
        expect(ActionMailer::Base.deliveries.last.subject).to eq(
          "[#{application_name} TEST] #{subject}"
        )
      end

      it 'responds with success' do
        post :create, hpkp_report: hpkp_report

        expect(response).to be_success
        expect(response.body).to eq ''
      end
    end
  end
end
