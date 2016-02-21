require 'spec_helper'

describe Security::CspRulesetBuilder do
  describe '.build' do
    let(:configuration) do
      instance_double(
        'Security::Configuration',
        external_connect_sources: [],
        external_font_sources: ['fonts.gstatic.com'],
        external_frame_sources: [],
        external_media_sources: [],
        external_object_sources: [],
        external_image_sources: ['secure.gravatar.com', 'graph.facebook.com', 'pbs.twimg.com'],
        external_script_sources: ['ssl.google-analytics.com', 'ajax.googleapis.com'],
        external_style_sources: ['fonts.googleapis.com']
      )
    end
    subject { described_class.build(configuration: configuration) }
    let(:virtual_host) { Faker::Internet.domain_name }
    before { allow(configuration).to receive(:virtual_host).and_return(virtual_host) }

    context 'when ssl is enabled' do
      before { allow(configuration).to receive(:ssl_enabled?).and_return(true) }

      context 'when a asset host has been provided' do
        let(:asset_host) { Faker::Internet.domain_name }
        before { allow(configuration).to receive(:asset_host).and_return(asset_host) }

        it 'should build a csp config with https directives' do
          should eq(
            report_only: false,
            default_src: ['https:', asset_host],
            connect_src: ["'self'", asset_host],
            font_src: ['https:', asset_host, 'data:', 'fonts.gstatic.com'],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'https:',
              asset_host,
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            media_src: ['https:', asset_host],
            object_src: ["'none'"],
            script_src: ['https:', asset_host, 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['https:', asset_host, "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["https://#{virtual_host}/security/csp_report"]
          )
        end

        context 'when the virtual_host is nil' do
          let(:virtual_host) { nil }

          it 'should set the report_uri to a relative path' do
            expect(subject[:report_uri]).to eq ['/security/csp_report']
          end
        end

        it 'should only include Content Security Policy level 1.0 flags' do
          directives = subject.keys.reject { |k| %i(report_only).include? k }
          directives.each do |flag|
            expect(SecureHeaders::ContentSecurityPolicy::DIRECTIVES_1_0).to include(flag)
          end
        end

        it 'should return a valid configuration' do
          SecureHeaders::ContentSecurityPolicy.validate_config! subject
        end
      end

      context 'when a asset host has not been provided' do
        before { allow(configuration).to receive(:asset_host).and_return(nil) }

        it 'should build a csp config limited to localhost' do
          should eq(
            report_only: false,
            default_src: ['https:', "'self'"],
            connect_src: ["'self'"],
            font_src: ['https:', "'self'", 'data:', 'fonts.gstatic.com'],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'https:',
              "'self'",
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            media_src: ['https:', "'self'"],
            object_src: ["'none'"],
            script_src: ['https:', "'self'", 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['https:', "'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["https://#{virtual_host}/security/csp_report"]
          )
        end
      end
    end

    context 'when ssl is disabled' do
      before { allow(configuration).to receive(:ssl_enabled?).and_return(false) }

      context 'when a asset host has been provided' do
        let(:asset_host) { Faker::Internet.domain_name }
        before { allow(configuration).to receive(:asset_host).and_return(asset_host) }

        it 'should build a csp config without https directives' do
          should eq(
            report_only: false,
            default_src: ['http:', asset_host],
            connect_src: ["'self'", asset_host],
            font_src: ['http:', asset_host, 'data:', 'fonts.gstatic.com'],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'http:',
              asset_host,
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            media_src: ['http:', asset_host],
            object_src: ["'none'"],
            script_src: ['http:', asset_host, 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['http:', asset_host, "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["http://#{virtual_host}/security/csp_report"]
          )
        end
      end

      context 'when a asset host has not been provided' do
        before { allow(configuration).to receive(:asset_host).and_return(nil) }

        it 'should build a csp config limited to localhost' do
          should eq(
            report_only: false,
            default_src: ['http:', "'self'"],
            connect_src: ["'self'"],
            font_src: ['http:', "'self'", 'data:', 'fonts.gstatic.com'],
            frame_src: ["'none'"],
            img_src: [
              'data:',
              'http:',
              "'self'",
              'secure.gravatar.com',
              'graph.facebook.com',
              'pbs.twimg.com'
            ],
            media_src: ['http:', "'self'"],
            object_src: ["'none'"],
            script_src: ['http:', "'self'", 'ssl.google-analytics.com', 'ajax.googleapis.com'],
            style_src: ['http:', "'self'", "'unsafe-inline'", 'fonts.googleapis.com'],
            report_uri: ["http://#{virtual_host}/security/csp_report"]
          )
        end
      end
    end
  end
end
