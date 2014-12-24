require 'rails_helper'

describe 'pages/home.html.haml', type: :view do

  context do # Within default nesting
    it 'renders the home page' do
      render
    end
  end

end
