require 'spec_helper'

describe Logging do
  it 'should have a version' do
    expect(Logging::VERSION).to_not be_nil
  end
end
