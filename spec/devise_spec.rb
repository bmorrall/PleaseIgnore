require 'spec_helper'

describe 'Devise' do

  it 'should return the same message for invalid password or not found password' do
    expect(t('devise.failure.not_found_in_database')).to eq(t('devise.failure.invalid'))
  end
end
