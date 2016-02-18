require 'spec_helper'

describe Security::HpkpRulesetBuilder do
  describe '.build' do
    let(:virtual_host) { Faker::Internet.domain_name }
    let(:configuration) do
      instance_double(
        'Security::Configuration',
        virtual_host: virtual_host,
        ssl_enabled?: true,
        hpkp_public_keys: []
      )
    end
    subject { described_class.build(configuration: configuration) }

    context 'with a primary and secondary hpkp public key' do
      let(:primary_key) { Faker::Number.hexadecimal(16) }
      let(:backup_key) { Faker::Number.hexadecimal(16) }
      before do
        allow(configuration).to receive(:hpkp_public_keys).and_return([primary_key, backup_key])
      end

      context 'with ssl enabled' do
        before { allow(configuration).to receive(:ssl_enabled?).and_return(true) }

        it 'should return a https configuration' do
          should eq(
            enforce: true,
            max_age: 60.days.to_i,
            include_subdomains: true,
            report_uri: "https://#{virtual_host}/security/hpkp_report",
            pins: [
              { sha256: primary_key },
              { sha256: backup_key }
            ]
          )
        end
      end

      context 'when the virtual_host is nil' do
        let(:virtual_host) { nil }

        it 'should set the report_uri to a relative path' do
          expect(subject[:report_uri]).to eq '/security/hpkp_report'
        end
      end

      context 'with ssl disabled' do
        before { allow(configuration).to receive(:ssl_enabled?).and_return(false) }

        it 'should return a http configuration' do
          should eq(
            enforce: true,
            max_age: 60.days.to_i,
            include_subdomains: true,
            report_uri: "http://#{virtual_host}/security/hpkp_report",
            pins: [
              { sha256: primary_key },
              { sha256: backup_key }
            ]
          )
        end
      end
    end

    it 'should return false when there are no hpkp_public_keys' do
      expect(configuration).to receive(:hpkp_public_keys).and_return([])
      expect(subject).to be false
    end

    it 'should return false when there is one hpkp_public_keys' do
      expect(configuration).to receive(:hpkp_public_keys).and_return([double('public key')])
      expect(subject).to be false
    end
  end
end
