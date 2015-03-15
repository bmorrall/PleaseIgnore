# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_id   :integer
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
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
