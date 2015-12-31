require 'rails_helper'

describe Concerns::Users::DeviseTokenAuthentication do
  class TestUser < ActiveRecord::Base
    include Concerns::Users::DeviseTokenAuthentication
    self.table_name = :users
  end
  subject { TestUser.new }

  describe 'Associations' do
    it { should have_many(:authentication_tokens).dependent(:destroy) }
  end
end
