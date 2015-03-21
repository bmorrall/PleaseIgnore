require 'rails_helper'

describe 'Factories' do
  it 'should have valid factories' do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
