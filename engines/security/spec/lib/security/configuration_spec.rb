require 'spec_helper'

describe Security::Configuration, type: :model do
  subject(:instance) { described_class.new }

  describe 'Validations' do
    it { should validate_presence_of(:virtual_host) }
    it { should allow_value('pleaseignore.com').for(:virtual_host) }
    it { should allow_value('test').for(:virtual_host) }

    it { should_not validate_presence_of(:asset_host) }
    it { should allow_value('assets.pleaseignore.com').for(:asset_host) }
    it { should allow_value('test').for(:asset_host) }
    it { should allow_value(nil).for(:asset_host) }

    it { should allow_value(true).for(:ssl_enabled) }
    it { should allow_value(false).for(:ssl_enabled) }
  end

  describe '#external_connect_sources' do
    subject { instance.external_connect_sources }

    it 'should return sources added to it' do
      connect_source = Faker::Internet.domain_name
      instance.add_external_connect_source(connect_source)
      expect(subject).to eq [connect_source]
    end
  end

  describe '#external_font_sources' do
    subject { instance.external_font_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_font_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_frame_sources' do
    subject { instance.external_frame_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_frame_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_image_sources' do
    subject { instance.external_image_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_image_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_media_sources' do
    subject { instance.external_media_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_media_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_object_sources' do
    subject { instance.external_object_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_object_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_script_sources' do
    subject { instance.external_script_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_script_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#external_style_sources' do
    subject { instance.external_style_sources }

    it 'should return sources added to it' do
      source = Faker::Internet.domain_name
      instance.add_external_style_source(source)
      expect(subject).to eq [source]
    end
  end

  describe '#hpkp_public_keys' do
    subject { instance.hpkp_public_keys }

    it 'should return sources added to it' do
      source = Faker::Number.hexadecimal(16)
      instance.add_hpkp_public_key(source)
      expect(subject).to eq [source]
    end
  end
end
