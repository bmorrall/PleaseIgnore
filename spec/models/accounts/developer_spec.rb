# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string           not null
#  name             :string
#  nickname         :string
#  image            :string
#  website          :string
#  oauth_token      :string
#  oauth_secret     :string
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string
#  deleted_at       :datetime
#
# Indexes
#
#  index_accounts_on_deleted_at  (deleted_at)
#  index_accounts_on_user_id     (user_id)
#

require 'rails_helper'

describe Accounts::Developer, type: :model do

  describe 'validations' do
    it { is_expected.to allow_value('Accounts::Developer').for(:type) }
  end

  describe '#account_uid' do
    it 'returns the uid' do
      subject.uid = 'example_uid'
      expect(subject.account_uid).to eq('example_uid')
    end
  end

  describe '#enabled?' do
    context 'with a user account' do
      before(:each) { subject.user = build_stubbed(:user) }
      it { is_expected.not_to be_enabled }
    end
    context 'without a user' do
      it { is_expected.not_to be_enabled }
    end
  end

  describe '#provider_name' do
    it 'should return Developer' do
      expect(subject.provider_name).to eq('Developer')
    end
  end
end
