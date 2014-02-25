require 'spec_helper'

describe "contacts/thank_you.html.haml" do

  context do # Within default nesting
    it "renders a thank you to the user" do
      render

      rendered.should have_content('Thank you for Contacting PleaseIgnore')
    end
  end

end
