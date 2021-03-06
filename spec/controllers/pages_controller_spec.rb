require 'rails_helper'

describe PagesController, type: :controller do
  describe 'GET show' do
    context 'as a visitor' do
      # Frontend Pages
      %w(home styles).each do |page|
        context "with GET to /docs/#{page}" do
          before(:each) { get :show, id: page }
          it { is_expected.to render_template(page) }
          it { is_expected.to render_with_layout('frontend_static') }
          it { expect(response.content_type).to eq('text/html') }
          it { is_expected.not_to set_flash }

          it 'should set the cache headers' do
            expect(response.headers['Cache-Control']).to eq('public, max-age=600')
          end
        end
      end

      # Documentation
      %w(privacy terms).each do |page|
        context "with GET to /docs/#{page}" do
          before(:each) { get :show, id: page }
          it { is_expected.to render_template(page) }
          it { is_expected.to render_with_layout('backend_static') }
          it { expect(response.content_type).to eq('text/html') }
          it { is_expected.not_to set_flash }

          it 'should set the cache headers' do
            expect(response.headers['Cache-Control']).to eq('public, max-age=600')
          end
        end
      end
    end
  end
end
