require 'spec_helper'

describe Logging do
  it 'should have a version' do
    expect(Logging::VERSION).to_not be_nil
  end

  describe '.log_error' do
    it 'should call Logging::ExceptionNotifier.notify with the given arguments' do
      exception = double('exception')
      additional_fields = double('additional_fields')

      expect(Logging::ExceptionNotifier).to receive(:notify).with(exception, additional_fields)
      Logging.log_error(exception, additional_fields)
    end
  end
end
