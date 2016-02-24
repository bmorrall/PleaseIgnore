require 'spec_helper'

describe Logging::Railtie do
  it 'should set the default log formatter to Logging::LogStashFormatter' do
    expect(Rails.logger.formatter).to be_kind_of(Logging::LogStashFormatter)
    expect(Rails.application.config.log_formatter).to be_kind_of(Logging::LogStashFormatter)
  end

  it 'should setup Lograge to use Logstash formatting' do
    lograge_config = Rails.application.config.lograge

    expect(lograge_config.enabled).to be(true)
    expect(lograge_config.logger).to be_kind_of(Logging::PassthroughLogger)
    expect(lograge_config.formatter).to be_kind_of(Lograge::Formatters::Logstash)
    expect(lograge_config.custom_options).to be_kind_of(Logging::LogrageEventParser)
  end
end
