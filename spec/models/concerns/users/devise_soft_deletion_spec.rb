require 'rails_helper'

describe Concerns::Users::DeviseSoftDeletion do
  class DeviseSoftDeletionTestUser < ActiveRecord::Base
    include Concerns::Users::DeviseSoftDeletion
    self.table_name = :users
  end
  subject(:instance) { DeviseSoftDeletionTestUser.new }

  describe '.expired?' do
    subject { instance.expired? }

    context 'when the user was soft deleted two months ago' do
      before { instance.deleted_at = (2.months + 1.day).ago }

      it { should be true }
    end
    context 'when the user was soft deleted less than two months ago' do
      before { instance.deleted_at = (2.months - 1.day).ago }

      it { should be false }
    end
    context 'when the user has not been soft deleted' do
      before { instance.deleted_at = nil }

      it { should be false }
    end
  end
end
