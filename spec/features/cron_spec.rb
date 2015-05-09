require 'rails_helper'

feature 'Cron Tasks', type: :feature do
  scenario 'Old authentication tokens should be removed daily' do
    user = create(:user)
    (Tiddle::TokenIssuer::MAXIMUM_TOKENS_PER_USER + 1).times do
      create :authentication_token, user: user
    end

    Sidekiq::Testing.inline! do
      expect do
        Cron.daily
      end.to change(AuthenticationToken, :count).by(-1)
    end

    expect(user.authentication_tokens.count).to eq Tiddle::TokenIssuer::MAXIMUM_TOKENS_PER_USER
  end
end
