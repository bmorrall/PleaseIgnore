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

require 'spec_helper'

describe Role, type: :model do
  describe 'Associations' do
    it { is_expected.to have_and_belong_to_many(:users) }
    it { is_expected.to belong_to(:resource) }
  end

  describe 'Validations' do
    it { is_expected.to allow_value('admin').for(:name) }
    it { is_expected.to allow_value('banned').for(:name) }

    it { is_expected.to_not allow_value('owner').for(:name) }

    context 'when the role has a resource' do
      before(:each) { subject.resource = build_stubbed(:organisation) }

      it { is_expected.to allow_value('owner').for(:name) }

      it { is_expected.to_not allow_value('admin').for(:name) }
      it { is_expected.to_not allow_value('banned').for(:name) }
    end
  end
end
