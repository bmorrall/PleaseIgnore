require 'spec_helper'

describe 'pages/terms.html.haml' do

  context do # Within default nesting
    it 'renders the terms page' do
      render

      assert_select 'h2', 'PleaseIgnore Terms of Service'
      assert_select 'h3#account-terms', 'Account Terms'
      assert_select 'h3#api-terms', 'API Terms'
      assert_select 'h3#payment-terms', 'Payment, Refunds, Upgrading and Downgrading Terms'
      assert_select 'h3#cancellation', 'Cancellation and Termination'
      assert_select 'h3#modifications', 'Modifications to the Service and Prices'
      assert_select 'h3#copyright', 'Copyright and Content Ownership'
      assert_select 'h3#general-conditions', 'General Conditions'
    end
  end

end
