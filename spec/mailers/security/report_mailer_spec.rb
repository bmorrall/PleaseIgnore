require 'rails_helper'

RSpec.describe Security::ReportMailer, type: :mailer do
  describe 'hpkp_report' do
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
    let(:mail) { described_class.hpkp_report(hpkp_report) }

    it 'renders the headers' do
      expect(mail.subject).to eq t('security.report_mailer.hpkp_report.subject')
      expect(mail.to).to eq(['security@pleaseignore.com'])
      expect(mail.from).to eq(['security@pleaseignore.com'])
    end

    it 'renders the hpkp report as pretty JSON' do
      hpkp_report.each do |key, _v|
        expect(mail.body.encoded).to include(key.to_s)
      end
    end
  end
end