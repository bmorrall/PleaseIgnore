require 'rails_helper'

describe PaperTrail::Version do
  describe 'Associations' do
    it { should belong_to(:item_owner) }
  end
end
