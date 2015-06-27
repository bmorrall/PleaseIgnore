require 'rails_helper'

describe 'pages/styles.html.haml' do
  context do # Within default nesting
    it 'renders the styles page' do
      render
    end
  end
end
