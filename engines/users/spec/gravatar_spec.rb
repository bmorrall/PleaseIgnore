require 'spec_helper'

describe Gravatar do
  describe '.gravatar_image_url' do
    context 'with a email address' do
      let(:email) { 'test@example.com' }

      context 'with no size argument' do
        it 'returns a 128px gravatar image url' do
          md5 = '55502f40dc8b7c769880b10874abc9d0'
          expected = "https://secure.gravatar.com/avatar/#{md5}.png?s=128&r=PG&d=identicon"
          expect(described_class.gravatar_image_url(email)).to eq(expected)
        end
      end
      %w(16 32 64 128).each do |size|
        context "with a size argument of #{size}" do
          it "returns a #{size}px gravatar image url" do
            md5 = '55502f40dc8b7c769880b10874abc9d0'
            expected = "https://secure.gravatar.com/avatar/#{md5}.png?s=#{size}&r=PG&d=identicon"
            expect(described_class.gravatar_image_url(email, size)).to eq(expected)
          end
        end
      end
    end
    context 'with a blank email address' do
      it 'returns nil' do
        expect(described_class.gravatar_image_url('')).to be_nil
      end
    end
    context 'with a nil email address' do
      it 'returns nil' do
        expect(described_class.gravatar_image_url(nil)).to be_nil
      end
    end
  end
end
