require 'rails_helper'

describe Concerns::Users::DeviseTokenAuthentication do
  class DeviseTokenAuthenticationTestUser < ActiveRecord::Base
    include Concerns::Users::DeviseTokenAuthentication
    self.table_name = :users
  end
  subject { DeviseTokenAuthenticationTestUser.new }

  describe 'Associations' do
    it { should have_many(:authentication_tokens).dependent(:destroy) }
  end
end
