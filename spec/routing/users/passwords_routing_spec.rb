require "spec_helper"

describe Users::PasswordsController do
  describe "routing" do

    it "routes to #new" do
      get("/users/password/new").should route_to("users/passwords#new")
    end

    it "routes to #create" do
      post("/users/password").should route_to("users/passwords#create")
    end

    it "routes to #edit" do
      get("/users/password/edit").should route_to("users/passwords#edit")
    end

    it "routes to #update" do
      put("/users/password").should route_to("users/passwords#update")
      patch("/users/password").should route_to("users/passwords#update")
    end

  end
end
