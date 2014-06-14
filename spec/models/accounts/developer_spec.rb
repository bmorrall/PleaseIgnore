# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  uid              :string(255)      not null
#  name             :string(255)
#  nickname         :string(255)
#  image            :string(255)
#  website          :string(255)
#  oauth_token      :string(255)
#  oauth_secret     :string(255)
#  oauth_expires_at :datetime
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  type             :string(255)
#

require 'spec_helper'

describe Accounts::Developer do

  describe 'validations' do
    it { should allow_value('Accounts::Developer').for(:type) }
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
      it { should_not be_enabled }
    end
    context 'without a user' do
      it { should_not be_enabled }
    end
  end

  describe '#provider_name' do
    it 'should return Developer' do
      expect(subject.provider_name).to eq('Developer')
    end
  end
end
