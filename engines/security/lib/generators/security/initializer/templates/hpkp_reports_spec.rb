require 'rails_helper'

RSpec.describe 'Security::HpkpReports', type: :request do
  include ActiveSupport::Testing::TimeHelpers

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
        }.to_json
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      subject = I18n.t('security.report_mailer.hpkp_report.subject')
      expect(ActionMailer::Base.deliveries.last.to).to eq(['security@example.com'])
      expect(ActionMailer::Base.deliveries.last.subject).to eq(subject)
    end

    describe 'Rake::Attack limiting' do
      it 'limits requests to 5 a minute' do
        travel_to 1.minute.ago do
          # Run the allowed number of requests
          5.times { post('/security/hpkp_report') }
          expect(response.status).to_not eq(429)

          # Run the forbidden request
          post('/security/hpkp_report')
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
        post('/security/hpkp_report')
        expect(response.status).to_not be(429)
      end
    end
  end
end
