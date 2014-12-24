# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  resource_id   :integer
#  resource_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

describe Role, type: :model do

  describe 'associations' do
    it { is_expected.to have_and_belong_to_many(:users) }
    it { is_expected.to belong_to(:resource) }
  end

  describe 'validations' do
    it { is_expected.to allow_value('admin').for(:name) }
    it { is_expected.to allow_value('banned').for(:name) }
  end
end
