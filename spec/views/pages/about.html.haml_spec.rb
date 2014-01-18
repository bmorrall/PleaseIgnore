require 'spec_helper'

describe "pages/about.html.haml" do

  context do # Within default nesting
    it "renders the about page" do
      render
    end
  end

end
