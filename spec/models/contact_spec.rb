require 'spec_helper'

describe Contact do

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:body) }
    it { should_not validate_presence_of(:referer) }
  end

  describe 'Attributes' do
    it 'should include name' do
      subject.name = 'Contact Name'
      expect(subject.attributes[:name]).to eq('Contact Name')
    end
    it 'should include email' do
      subject.email = 'email@example.com'
      expect(subject.attributes[:email]).to eq('email@example.com')
    end
    it 'should include body' do
      subject.body = 'Contact Body'
      expect(subject.attributes[:body]).to eq('Contact Body')
    end
    it 'should include referer' do
      subject.referer = 'http://pleaseignore.com'
      expect(subject.attributes[:referer]).to eq('http://pleaseignore.com')
    end
  end

end
