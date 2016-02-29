# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  name                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#

require 'spec_helper'

describe User, type: :model do
  subject(:instance) { described_class.new }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_acceptance_of(:terms_and_conditions) }

    describe 'email validation' do
      it 'should validate the uniqueness of email' do
        create :user
        is_expected.to validate_uniqueness_of(:email).case_insensitive
      end

      context 'when email is required' do
        before(:each) { allow(subject).to receive(:email_required?).and_return(true) }

        it { should validate_presence_of :email }
      end
      context 'when email is not required' do
        before(:each) { allow(subject).to receive(:email_required?).and_return(false) }

        it { should_not validate_presence_of :email }
      end

      context 'when email has changed' do
        before(:each) { allow(subject).to receive(:email_changed?).and_return(true) }

        %w(
          a.b.c@example.com
          test_mail@gmail.com
          any@any.net
          email@test.br
          123@mail.test
          1☃3@mail.test
        ).each do |valid_email|
          it { should allow_value(valid_email).for(:email) }
        end
        %w(
          invalid_email_format
          123
          $$$
          ()
          ☃
          bla@bla.
        ).each do |invalid_email|
          it { should_not allow_value(invalid_email).for(:email) }
        end
      end

      context 'with a soft_deleted user with the same email' do
        before(:each) { create(:user, :soft_deleted, email: 'test@example.com') }

        it 'should not allow the same email to be used' do
          should_not allow_value('test@example.com').for(:email)
        end
      end
    end

    describe 'password validation' do
      context 'when password is required' do
        it { should validate_presence_of(:password) }
        it { should validate_confirmation_of(:password) }
        it { should validate_length_of(:password).is_at_least(8).is_at_most(128) }
      end
    end
  end

  describe '#expired?' do
    subject { instance.expired? }

    context 'when the user was soft deleted two months ago' do
      before { instance.deleted_at = 2.months.ago }

      it { should be true }
    end
    context 'when the user was soft deleted less than two months ago' do
      before { instance.deleted_at = (2.months - 1.minute).ago }

      it { should be false }
    end
    context 'when the user has not been soft deleted' do
      before { instance.deleted_at = nil }

      it { should be false }
    end
  end

  describe '#no_login_password?' do
    subject { instance.no_login_password? }

    it 'returns true when the encrypted_password is blank' do
      is_expected.to be(true)
    end

    it 'returns true if the password has been assigned but not saved' do
      instance.password = Faker::Lorem.word
      is_expected.to be(true)
    end

    context 'when the user has a encrypted_password' do
      let(:instance) { create(:user) }

      it { is_expected.to be(false) }

      it 'should remain false when a new password has been set' do
        instance.password = Faker::Lorem.word
        is_expected.to be(false)
      end
    end
  end

  context 'DeviseOverrides' do
    describe '#active_for_authentication?' do
      context 'when the user is deleted' do
        it 'should not be active for authentication' do
          user = User.new
          user.deleted_at = 3.hours.ago
          expect(user.active_for_authentication?).to be false
        end
      end
    end

    describe '#confirmation_required?' do
      it 'should not require confirmation' do
        user = User.new
        expect(user.confirmation_required?).to be false
      end
    end

    describe '#email_required?' do
      it 'should not require an email address for expired users' do
        user = User.new
        user.deleted_at = User::EXPIRATION_PERIOD.ago
        expect(user.email_required?).to be false
      end
    end

    describe '#inactive_message' do
      it 'should return a deleted_account inactive message for deleted users' do
        user = User.new
        user.deleted_at = Time.zone.now
        expect(user.inactive_message).to eq :deleted_account
      end
    end
  end

  describe '#gravatar_image' do
    let(:instance) { described_class.new }

    context 'with a email address' do
      let(:email) { Faker::Internet.email }
      before(:each) { instance.email = email }

      context 'with no size argument' do
        subject { instance.gravatar_image }

        it 'calls the gravatar service with email and a size argument of 128' do
          gravatar_url = double('gravatar url')
          expect(Gravatar).to receive(:gravatar_image_url).with(email, 128).and_return(gravatar_url)
          expect(subject).to eq gravatar_url
        end
      end
      %w(16 32 64 128).each do |size|
        context "with a size argument of #{size}" do
          subject { instance.gravatar_image(size.to_i) }

          it "calls the gravatar service with email and a size argument of #{size}" do
            gravatar_url = double('gravatar url')
            expect(Gravatar).to receive(:gravatar_image_url).with(email, size.to_i)
              .and_return(gravatar_url)
            expect(subject).to eq gravatar_url
          end
        end
      end
    end
  end
end
