require 'spec_helper'

describe Users::OmniauthCallbacksController do
  describe "routing" do

    it "routes to #facebook callback" do
      post("/users/auth/facebook/callback").should route_to("users/omniauth_callbacks#facebook")
    end

    it "routes to #twitter callback" do
      post("/users/auth/twitter/callback").should route_to("users/omniauth_callbacks#twitter")
    end

    it "routes to #github callback" do
      post("/users/auth/github/callback").should route_to("users/omniauth_callbacks#github")
    end

    it "routes to #google_oauth2 callback" do
      post("/users/auth/google_oauth2/callback").should route_to("users/omniauth_callbacks#google_oauth2")
    end

  end
end
