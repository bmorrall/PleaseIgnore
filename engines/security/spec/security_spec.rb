require 'spec_helper'

describe Security do
  it 'should have a version' do
    expect(Security::VERSION).to_not be_nil
  end

  describe '#configure' do
    before do
      Security.configure do |config|
        config.virtual_host = 'example.com'
      end
    end

    it 'stores configuration values' do
      configuration = Security.configuration

      expect(configuration.virtual_host).to eq 'example.com'
    end
  end
end
