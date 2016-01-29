require 'rails_helper'

RSpec.describe 'Security::HpkpReports', type: :request do
  describe 'POST /security/hpkp_reports' do
    it 'sends a HPKP Report email' do
      expect do
        post '/security/hpkp_report', {
          "date-time": DateTime.now.rfc3339,
          "hostname": 'example.com',
          "port": '80',
          "effective-expiration-date": DateTime.now.rfc3339,
          "include-subdomains": false,
          "noted-hostname": 'example.com',
          "served-certificate-chain": [
            Faker::Internet.slug
          ],
          "validated-certificate-chain": [
            Faker::Internet.slug
          ],
          "known-pins": [
            Faker::Internet.slug
          ]
        }.to_json, 'CONTENT_TYPE' => 'application/json'
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      subject = t('security.report_mailer.hpkp_report.subject')
      expect(ActionMailer::Base.deliveries.last.subject).to eq(
        "[#{application_name} TEST] #{subject}"
      )
    end
  end
end
