require 'rails_helper'

RSpec.describe 'organisations/show', type: :view do
  before(:each) do
    @organisation = assign(:organisation, create(:organisation))
  end

  it 'renders the page title' do
    render

    assert_select '.page-header h3', text: @organisation.name
  end
end
