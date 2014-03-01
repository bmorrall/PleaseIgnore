require 'spec_helper'

describe "Pages" do

  # http://pivotallabs.com/tdd-action-caching-in-rails-3/
  around do |example|
    store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
    silence_warnings { Object.const_set "RAILS_CACHE", ActionController::Base.cache_store }

    example.run

    silence_warnings { Object.const_set "RAILS_CACHE", store }
    ActionController::Base.cache_store = store
  end
  before(:each) { Rails.cache.clear }

  describe "GET /" do
    context "as a visitor" do
      it "renders the home page" do
        get root_url
        response.status.should be(200)
      end
      it "caches the home page" do
        get root_url
        ActionController::Base.cache_store.exist?("views/www.example.com/index").should be_true
      end
    end
  end

  describe "GET /home" do
    context 'as a visitor' do
      it 'redirects to the root_url' do
        get page_path('home')
        response.should redirect_to(root_url)
        follow_redirect!
        response.status.should be(200)
      end
    end
  end

  %w(styles privacy terms).each do |page|
    describe "GET /#{page}" do
      context "as a visitor" do
        it "renders the #{page} page" do
          get page_path(page)
          response.status.should be(200)
        end
        it "caches the #{page} page" do
          cache_path = "views/www.example.com#{page_path(page)}"
          get page_path(page)
          ActionController::Base.cache_store.exist?(cache_path).should be_true
        end
      end
    end
  end

end
