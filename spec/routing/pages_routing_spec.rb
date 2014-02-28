require "spec_helper"

describe PagesController do
  describe "routing" do

    it "routes root to #show" do
      get("/").should route_to("pages#show", id: 'home')
    end

    %w(styles privacy terms).each do |page|
      it "routes /#{page} to #show" do
        get("/#{page}").should route_to("pages#show", id: page)
      end
    end
  end
end
