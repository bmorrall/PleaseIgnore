require "spec_helper"

describe SupportMailer do
  describe "contact_email" do
    let(:mail) { SupportMailer.contact_email }

    it "renders the headers" do
      mail.subject.should eq("Contact email")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
