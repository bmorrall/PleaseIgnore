require 'spec_helper'

describe 'pages/home.html.haml' do

  context do # Within default nesting
    it 'renders the home page' do
      render
    end
  end

end
