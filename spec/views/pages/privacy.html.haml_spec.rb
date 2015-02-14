require 'rails_helper'

describe 'pages/privacy.html.haml', type: :view do

  context do # Within default nesting
    it 'renders the privacy page' do
      render

      assert_select 'h2', I18n.t('pages.privacy.page_title')
      assert_select 'h3#general-information', 'General Information'
      assert_select 'h3#information-gathering-and-usage', 'Information Gathering and Usage'
      assert_select 'h3#cookies', 'Cookies'
      assert_select 'h3#data-storage', 'Data Storage'
      assert_select 'h3#disclosure', 'Disclosure'
      assert_select 'h3#changes', 'Changes'
      assert_select 'h3#questions', 'Questions'
    end
  end

end
