require "spec_helper"

describe Users::AccountsController do
  describe "routing" do

    it "routes to #sort" do
      post("/users/accounts/sort").should route_to("users/accounts#sort")
    end

  end
end
