# == Schema Information
#
# Table name: authentication_tokens
#
#  id           :integer          not null, primary key
#  body         :string
#  user_id      :integer
#  last_used_at :datetime
#  ip_address   :string
#  user_agent   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_authentication_tokens_on_user_id  (user_id)
#

require 'rails_helper'

RSpec.describe AuthenticationToken, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
  end
end
