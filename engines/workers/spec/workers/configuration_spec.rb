require 'spec_helper'

describe Workers::Configuration do
  subject(:instance) { described_class.new }

  describe '#sidekiq_namespace' do
    it 'should default to "sidekiq"' do
      expect(instance.sidekiq_namespace).to eq 'sidekiq'
    end
  end
end
