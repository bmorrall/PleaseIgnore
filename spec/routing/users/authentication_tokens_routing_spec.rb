require "rails_helper"

RSpec.describe Users::AuthenticationTokensController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/users/authentication_tokens").to route_to("users/authentication_tokens#index")
    end

    it "routes to #new" do
      expect(:get => "/users/authentication_tokens/new").to route_to("users/authentication_tokens#new")
    end

    it "routes to #show" do
      expect(:get => "/users/authentication_tokens/1").to route_to("users/authentication_tokens#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/users/authentication_tokens/1/edit").to route_to("users/authentication_tokens#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/users/authentication_tokens").to route_to("users/authentication_tokens#create")
    end

    it "routes to #update" do
      expect(:put => "/users/authentication_tokens/1").to route_to("users/authentication_tokens#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/authentication_tokens/1").to route_to("users/authentication_tokens#destroy", :id => "1")
    end

  end
end
