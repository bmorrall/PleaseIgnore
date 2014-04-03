require 'spec_helper'

describe PagesController do

  describe 'GET show' do
    context 'as a visitor' do
      %w(home styles privacy terms).each do |page|
        context "with GET to /#{page}" do
          before(:each) { get :show, id: page }
          it { should render_template(page) }
          it { should render_with_layout(:application) }
          it { expect(response.content_type).to eq('text/html') }
          it { should_not set_the_flash }
        end
      end
    end
  end

end

