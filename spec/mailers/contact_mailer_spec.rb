require 'rails_helper'

describe ContactMailer, type: :mailer do
  describe 'support_email' do
    let(:mail) { described_class.support_email(contact_attributes) }
    let(:user_agent) { Faker::Internet.user_agent }
    let(:contact_attributes) do
      {
        name: 'Test User',
        email: 'test@example.com',
        body: 'This is the body',
        referer: 'http://wavedigital.com.au',
        user_agent: user_agent
      }
    end

    it 'renders the headers' do
      expect(mail.subject).to eq t('contact_mailer.support_email.subject')
      expect(mail.to).to eq(['support@pleaseignore.com'])
      expect(mail.from).to eq(['contact@pleaseignore.com'])
    end

    it 'renders the body' do
      body = mail.body.encoded
      expect(body).to match("You have received a Contact Email from #{application_name}")
      expect(body).to match('Test User')
      expect(body).to match('test@example.com')
      expect(body).to match('This is the body')
      expect(body).to match('http://wavedigital.com.au')
      expect(body).to include(user_agent)
    end
  end
end
