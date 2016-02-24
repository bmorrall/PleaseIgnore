require 'spec_helper'

describe Logging::LogStashFormatter do
  subject(:instance) { described_class.new }

  describe '.call' do
    context 'when logstash formatting is enabled' do
      before { allow(Logging).to receive(:skip_formatting?).and_return(false) }

      it 'should parse the message as valid JSON' do
        message = Faker::Lorem.sentence
        result = instance.call('INFO', Time.now, nil, message)
        expect { JSON.parse(result) }.to_not raise_error
      end

      it 'should include message, severity, progname, tags, and timestamp in the result' do
        severity = 'WARN'
        time = Time.iso8601('2013-01-01T00:00:00.000Z')
        progname = Faker::Lorem.word.downcase
        message = Faker::Lorem.sentence
        tags = Faker::Lorem.words

        result = instance.tagged(tags) { instance.call(severity, time, progname, message) }
        result = JSON.parse(result)
        expect(result['message']).to eq message
        expect(result['@severity']).to eq severity
        expect(result['@timestamp']).to eq '2013-01-01T00:00:00.000Z'
        expect(result['@progname']).to eq progname
        expect(result['@tags']).to eq tags
      end

      it 'should not format debug messages' do
        message = Faker::Lorem.sentence
        result = instance.call('DEBUG', Time.now, nil, message)
        expect(result).to eq(message + "\n")
      end
    end

    context 'when skip formatting is enabled' do
      before { allow(Logging).to receive(:skip_formatting?).and_return(true) }

      it 'should pass through message' do
        message = Faker::Lorem.sentence

        result = instance.call('INFO', Time.now, nil, message)
        expect(result).to eq(message + "\n")
      end
    end
  end
end
