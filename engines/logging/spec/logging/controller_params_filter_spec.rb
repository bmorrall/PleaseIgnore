require 'spec_helper'

describe Logging::ControllerParamsFilter do
  describe '.filter' do
    it 'removes the request forgery token' do
      token = Faker::Lorem.words.join('_').downcase
      allow(ActionController::Base).to receive(:request_forgery_protection_token).and_return(token)

      result = described_class.filter(token => 'blarg')
      expect(result).to eq({})
    end

    it 'removes tokens starting with an underscore' do
      result = described_class.filter('_foo' => 24, 'bar' => 42, '__baz' => 12)
      expect(result).to eq('bar' => 42)
    end

    it 'replaces filtered parameters' do
      banned_words = Faker::Lorem.words.map(&:downcase).map(&:to_sym)
      allow(Rails.application.config).to receive(:filter_parameters).and_return(banned_words)

      params = Hash[banned_words.map { |word| [word.to_s, rand(1..42)] }]
      expected = Hash[banned_words.map { |word| [word.to_s, '[FILTERED]'] }]

      expect(described_class.filter(params)).to eq(expected)
    end

    it 'replaces nested filtered parameters' do
      banned_words = Faker::Lorem.words.map(&:downcase).map(&:to_sym)
      allow(Rails.application.config).to receive(:filter_parameters).and_return(banned_words)

      params = Hash[banned_words.map { |word| [word.to_s, rand(1..42)] }]
      expected = Hash[banned_words.map { |word| [word.to_s, '[FILTERED]'] }]

      expect(described_class.filter('foo' => params)).to eq('foo' => expected)
    end
  end
end
