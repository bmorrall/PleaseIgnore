require 'spec_helper'

describe "Pages" do

  describe "GET /" do
    context "as a visitor" do
      it "renders the welcome page" do
        get root_url
        response.status.should be(200)
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
      end
    end
  end

end
