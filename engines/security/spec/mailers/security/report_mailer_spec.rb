require 'spec_helper'

RSpec.describe Security::ReportMailer, type: :mailer do
  describe 'csp_report' do
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
    let(:mail) { described_class.csp_report(csp_report) }

    it 'renders the headers' do
      expect(mail.subject).to eq t('security.report_mailer.csp_report.subject')
      expect(mail.to).to eq(['security@example.com'])
      expect(mail.from).to eq(['security@example.com'])
    end

    it 'renders the csp report as pretty JSON' do
      expect(mail.body.encoded).to match(JSON.pretty_generate(csp_report).gsub("\n", "\r\n"))
    end
  end

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
      expect(mail.to).to eq(['security@example.com'])
      expect(mail.from).to eq(['security@example.com'])
    end

    it 'renders the hpkp report as pretty JSON' do
      hpkp_report.each do |key, _v|
        expect(mail.body.encoded).to include(key.to_s)
      end
    end
  end
end
