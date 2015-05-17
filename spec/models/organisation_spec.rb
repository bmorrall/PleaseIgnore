# == Schema Information
#
# Table name: organisations
#
#  id         :integer          not null, primary key
#  name       :string
#  permalink  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organisations_on_permalink  (permalink) UNIQUE
#

require 'rails_helper'

RSpec.describe Organisation, type: :model do
  describe 'assign permalink validation callback' do
    it 'should set permalink to a downcased and dasherized name' do
      subject.name = 'This is a Company Name'
      subject.validate
      expect(subject.permalink).to eq('this-is-a-company-name')
    end
    it 'should trim leading and trailing whitespace' do
      subject.name = '  this   '
      subject.validate
      expect(subject.permalink).to eq('this')
    end
    it 'should normalize any non english characters' do
      subject.name = 'àáâãäåçèéêëæ'
      subject.validate
      expect(subject.permalink).to eq('aaaaaaceeeeae')
    end
    it 'should override a blank permalink' do
      subject.name = 'Foo Bar'
      subject.permalink = ''
      subject.validate
      expect(subject.permalink).to eq('foo-bar')
    end
    it 'should not override an existing permalink' do
      subject.name = 'Foo Bar'
      subject.permalink = 'blargh'
      subject.validate
      expect(subject.permalink).to eq('blargh')
    end
  end

  describe 'name validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'permalink validations' do
    it { should validate_presence_of(:permalink) }

    it 'should validate uniqueness of permalink' do
      create :organisation
      should validate_uniqueness_of(:permalink)
    end

    it { should allow_value('a').for(:permalink) }
    it { should allow_value('abcdef').for(:permalink) }
    it { should allow_value('a-bcde-f').for(:permalink) }
    it { should_not allow_value('abcdef-').for(:permalink) }
    it { should_not allow_value('-abcdef').for(:permalink) }

    it { should_not allow_value('about').for(:permalink) }
    it { should_not allow_value('admin').for(:permalink) }
    it { should_not allow_value('announce').for(:permalink) }
    it { should_not allow_value('api').for(:permalink) }
    it { should_not allow_value('contact').for(:permalink) }
    it { should_not allow_value('dashboard').for(:permalink) }
    it { should_not allow_value('organisations').for(:permalink) }
    it { should_not allow_value('privacy').for(:permalink) }
    it { should_not allow_value('sidekiq').for(:permalink) }
    it { should_not allow_value('terms').for(:permalink) }
    it { should_not allow_value('users').for(:permalink) }
    it { should_not allow_value('utils').for(:permalink) }
    it { should_not allow_value('wp-admin').for(:permalink) }
    it { should_not allow_value('wp-content').for(:permalink) }
  end
end
