require "spec_helper"

describe HighVoltage::PagesController do
  describe "routing" do

    it "routes root to #show" do
      get("/").should route_to("high_voltage/pages#show", id: 'home')
    end

  end
end
