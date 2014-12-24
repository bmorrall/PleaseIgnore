require 'rails_helper'

describe SupportMailer, type: :mailer do
  describe 'contact_email' do
    let(:mail) { SupportMailer.contact_email(contact_email_attributes) }
    let(:contact_email_attributes) do
      {
        name: 'Test User',
        email: 'test@example.com',
        body: 'This is the body',
        referer: 'http://wavedigital.com.au'
      }
    end

    it 'renders the headers' do
      expect(mail.subject).to eq t('support_mailer.contact_email.subject')
      expect(mail.to).to eq(['support@pleaseignore.com'])
      expect(mail.from).to eq(['contact@pleaseignore.com'])
    end

    it 'renders the body' do
      body = mail.body.encoded
      expect(body).to match('You have received a Contact Email from PleaseIgnore')
      expect(body).to match('Test User')
      expect(body).to match('test@example.com')
      expect(body).to match('This is the body')
      expect(body).to match('http://wavedigital.com.au')
    end
  end

end
