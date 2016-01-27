require 'rails_helper'

RSpec.describe Utils::SafePermalinkController, type: :controller do
  describe 'GET #create' do
    it 'returns a safe_permalink string' do
      value = Faker::Company.name
      get :create, value: value
      expect(JSON.parse(response.body)).to eq('result' => value.safe_permalink)
    end
  end
end
