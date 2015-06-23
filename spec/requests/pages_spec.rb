require 'rails_helper'

describe 'Pages', type: :request do
  enable_rails_cache

  def page_titles
    @page_titles ||= {
      'privacy' => t('pages.privacy.page_title'),
      'styles' => t('pages.styles.page_title'),
      'terms' => t('pages.terms.page_title')
    }
  end

  describe 'GET /' do
    context 'as a visitor' do
      it 'renders the home page' do
        get root_url
        expect(response.status).to be(200)
      end
      it 'caches the home page' do
        get root_url
        expect(ActionController::Base.cache_store.exist?('views/www.example.com/index')).to be(true)
      end
    end
    describe 'Metadata' do
      it 'includes the body class' do
        get root_url
        assert_select 'body.pages.pages-show.home-page'
      end
      it 'includes the page title' do
        get root_url
        assert_select 'title', application_name
      end
    end
  end

  describe 'GET /home' do
    context 'as a visitor' do
      it 'redirects to the root_url' do
        get page_path('home')
        expect(response).to redirect_to(root_url)
        follow_redirect!
        expect(response.status).to be(200)
      end
    end
  end

  %w(styles privacy terms).each do |page|
    describe "GET /#{page}" do
      context 'as a visitor' do
        it "renders the #{page} page" do
          get page_path(page)
          expect(response.status).to be(200)
        end
        it "caches the #{page} page" do
          cache_path = "views/www.example.com#{page_path(page)}"
          ActionController::Base.cache_store.delete(cache_path)
          get page_path(page)
          expect(ActionController::Base.cache_store.exist?(cache_path)).to be(true)
        end
      end
      describe 'Metadata' do
        it 'includes the body class' do
          get page_path(page)
          assert_select "body.pages.pages-show.#{page}-page"
        end
        it 'includes the page title' do
          get page_path(page)
          assert_select 'title', "#{application_name} | #{page_titles[page]}"
        end
      end
    end
  end
end
