require 'spec_helper'

describe "Passwords" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_password_path
        response.status.should be(200)
      end
    end
  end

end
