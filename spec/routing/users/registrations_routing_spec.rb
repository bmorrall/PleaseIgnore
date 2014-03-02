require "spec_helper"

describe Users::RegistrationsController do
  describe "routing" do

    it "routes to #cancel" do
      get("/users/cancel").should route_to("users/registrations#cancel")
    end

    it "routes to #new" do
      get("/users/sign_up").should route_to("users/registrations#new")
    end

    it "routes to #create" do
      post("/users").should route_to("users/registrations#create")
    end

    it "routes to #edit" do
      get("/users/edit").should route_to("users/registrations#edit")
    end

    it "routes to #update" do
      put("/users").should route_to("users/registrations#update")
      patch("/users").should route_to("users/registrations#update")
    end

    it "routes to #destroy" do
      delete("/users").should route_to("users/registrations#destroy")
    end

  end
end
