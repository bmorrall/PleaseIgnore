require "spec_helper"

describe SupportMailer do
  describe "contact_email" do
    let(:mail) { SupportMailer.contact_email(contact_email_attributes) }
    let(:contact_email_attributes) do
      {
        name: 'Test User',
        email: 'test@example.com',
        body: 'This is the body',
        referer: 'http://wavedigital.com.au'
      }
    end

    it "renders the headers" do
      mail.subject.should eq("PleaseIgnore Contact Email")
      mail.to.should eq(["support@pleaseignore.com"])
      mail.from.should eq(["contact@pleaseignore.com"])
    end

    it "renders the body" do
      body = mail.body.encoded
      body.should match("You have received a Contact Email from PleaseIgnore")
      body.should match("Test User")
      body.should match("test@example.com")
      body.should match("This is the body")
      body.should match('http://wavedigital.com.au')
    end
  end

end
