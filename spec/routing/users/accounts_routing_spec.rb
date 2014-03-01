require "spec_helper"

describe Users::AccountsController do
  describe "routing" do

    it "routes to #destroy" do
      delete("/users/accounts/1").should route_to("users/accounts#destroy", id: '1')
    end

    it "routes to #sort" do
      post("/users/accounts/sort").should route_to("users/accounts#sort")
    end

  end
end
