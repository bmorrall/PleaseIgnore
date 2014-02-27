require 'spec_helper'

describe PagesController do

  describe '#show' do
    context 'as a visitor' do
      %w(home styles privacy terms).each do |page|
        context "with GET request to /#{page}" do
          before(:each) { get :show, id: page }
          it { should render_template(page) }
          it { should render_with_layout(:application) }
          it { response.content_type.should eq('text/html') }
          it { should_not set_the_flash }
        end
        context "with GET request to /#{page} with pjax params" do
          before(:each) do
            request.env['HTTP_X_PJAX'] = true
            request.env['HTTP_X_PJAX_CONTAINER'] = '[data-pjax-container]'
            get :show, id: page, _pjax: '[data-pjax-container]'
          end
          it { should render_template(page) }
          it { should render_with_layout(:pjax) }
          it { response.content_type.should eq('text/html') }
          it { should_not set_the_flash }
          it 'sets the response headers to the current url' do
            expected_url = page == 'home' ? root_url : page_url(page)
            response.headers['X-PJAX-URL'].should eq(expected_url)
          end
        end
      end
    end
  end

end

