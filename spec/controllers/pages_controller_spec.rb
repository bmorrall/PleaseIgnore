require 'rails_helper'

describe PagesController, type: :controller do

  describe 'GET show' do
    context 'as a visitor' do
      %w(home styles privacy terms).each do |page|
        context "with GET to /#{page}" do
          before(:each) { get :show, id: page }
          it { is_expected.to render_template(page) }
          it { is_expected.to render_with_layout(:application) }
          it { expect(response.content_type).to eq('text/html') }
          it { is_expected.not_to set_the_flash }
        end
      end
    end
  end

end
