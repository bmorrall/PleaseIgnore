require 'rails_helper'

describe 'contacts/thank_you.html.haml', type: :view do

  context do # Within default nesting
    it 'renders a thank you to the user' do
      render

      assert_select 'h3', t('contacts.thank_you.page_title')
    end
  end

end
