require 'spec_helper'

describe "contacts/thank_you.html.haml" do

  context do # Within default nesting
    it "renders a thank you to the user" do
      render

      expect(rendered).to have_content('Thank you for Contacting PleaseIgnore')
    end
  end

end
