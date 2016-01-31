require 'rails_helper'
require 'security/csp_ruleset_builder'

describe Security::CspRulesetBuilder do
  let(:settings) { instance_double('Settings') }
  subject(:instance) { described_class.new(settings: settings) }

  describe '.build' do
    it 'creates a new instance of CspRulesetBuilder and returns the result' do
      build_results = double('build_results')
      ruleset_builder = instance_double(described_class.name, build: build_results)
      expect(described_class).to receive(:new).with(settings: settings).and_return(ruleset_builder)
      expect(described_class.build(settings: settings)).to eq build_results
    end
  end

  describe '#build' do
    subject { instance.build }
    let(:virtual_host) { Faker::Internet.domain_name }
    before { allow(settings).to receive(:virtual_host).and_return(virtual_host) }

    context 'when ssl is enabled' do
      before { allow(settings).to receive(:ssl_enabled?).and_return(true) }

      context 'when a asset host has been provided' do
        let(:asset_host) { Faker::Internet.domain_name }
        before { allow(settings).to receive(:asset_host).and_return(asset_host) }

        it 'should build a csp config with https directives' do
          should eq(
            enabled: true,
            default_src: ['https:', asset_host],
            base_uri: ["https://#{virtual_host}"],
            block_all_mixed_content: false,
            child_src: ["'none'"],
            font_src: ['https:', asset_host, 'data:', 'fonts.gstatic.com'],
            form_action: ["'self'"],
            frame_ancestors: ["'none'"],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'https:',
              asset_host,
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            object_src: ["'none'"],
            script_src: ['https:', asset_host, 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['https:', asset_host, "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["https://#{virtual_host}/security/csp_report"]
          )
        end
      end

      context 'when a asset host has not been provided' do
        before { allow(settings).to receive(:asset_host).and_return(nil) }

        it 'should build a csp config limited to localhost' do
          should eq(
            enabled: true,
            default_src: ['https:', "'self'"],
            base_uri: ["https://#{virtual_host}"],
            block_all_mixed_content: false,
            child_src: ["'none'"],
            font_src: ['https:', "'self'", 'data:', 'fonts.gstatic.com'],
            form_action: ["'self'"],
            frame_ancestors: ["'none'"],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'https:',
              "'self'",
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            object_src: ["'none'"],
            script_src: ['https:', "'self'", 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['https:', "'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["https://#{virtual_host}/security/csp_report"]
          )
        end
      end
    end

    context 'when ssl is disabled' do
      before { allow(settings).to receive(:ssl_enabled?).and_return(false) }

      context 'when a asset host has been provided' do
        let(:asset_host) { Faker::Internet.domain_name }
        before { allow(settings).to receive(:asset_host).and_return(asset_host) }

        it 'should build a csp config without https directives' do
          should eq(
            enabled: true,
            default_src: ['http:', asset_host],
            base_uri: ["http://#{virtual_host}"],
            block_all_mixed_content: false,
            child_src: ["'none'"],
            font_src: ['http:', asset_host, 'data:', 'fonts.gstatic.com'],
            form_action: ["'self'"],
            frame_ancestors: ["'none'"],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'http:',
              asset_host,
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            object_src: ["'none'"],
            script_src: ['http:', asset_host, 'www.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['http:', asset_host, "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["http://#{virtual_host}/security/csp_report"]
          )
        end
      end

      context 'when a asset host has not been provided' do
        before { allow(settings).to receive(:asset_host).and_return(nil) }

        it 'should build a csp config limited to localhost' do
          should eq(
            enabled: true,
            default_src: ['http:', "'self'"],
            base_uri: ["http://#{virtual_host}"],
            block_all_mixed_content: false,
            child_src: ["'none'"],
            font_src: ['http:', "'self'", 'data:', 'fonts.gstatic.com'],
            form_action: ["'self'"],
            frame_ancestors: ["'none'"],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'http:',
              "'self'",
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            object_src: ["'none'"],
            script_src: ['http:', "'self'", 'www.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['http:', "'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["http://#{virtual_host}/security/csp_report"]
          )
        end
      end
    end
  end
end
