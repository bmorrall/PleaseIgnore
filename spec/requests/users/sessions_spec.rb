require 'spec_helper'

describe "Sessions" do

  describe "GET new" do
    context "as a visitor" do
      it "renders the new page" do
        get new_user_session_path
        response.status.should be(200)
      end
    end
  end

end
