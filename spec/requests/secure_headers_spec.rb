require 'rails_helper'

describe 'SecureHeaders' do
  REJECTED_CSP_POLICIES = %i(
    plugin_types
    enforce
  ).freeze

  def format_csp_policies(csp_policies)
    csp_policies = csp_policies.reject { |k, _v| REJECTED_CSP_POLICIES.include?(k) }
    csp_policies.map do |k, v|
      key = k.to_s.dasherize
      if v.is_a?(Array)
        "#{key} #{v.join(' ')}"
      else
        "#{key} #{v}"
      end
    end
  end

  describe 'GET /' do
    context 'as a visitor' do
      it 'adds HTTP Secure Headers' do
        get root_url

        expect(response.headers['X-Frame-Options']).to eq('DENY')
        expect(response.headers['X-XSS-Protection']).to eq('1; mode=block')
        expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
        expect(response.headers['X-Download-Options']).to eq('noopen')
        expect(response.headers['X-Permitted-Cross-Domain-Policies']).to eq('none')
      end

      it 'adds Content Security Policy Headers' do
        get root_url

        csp_policies = Security::CspRulesetBuilder.build(settings: ::Settings.instance)
        csp_policies = format_csp_policies(csp_policies)

        content_security_policy = response.headers['Content-Security-Policy']
        csp_policies.each do |csp_policy|
          expect(content_security_policy).to match(csp_policy)
        end

        formatted_csp_policies = csp_policies.join('; ') + ';'
        expect(content_security_policy).to eq(formatted_csp_policies)
      end
    end
  end
end
