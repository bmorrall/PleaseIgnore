# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
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
#
# Indexes
#
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'rails_helper'

describe User, type: :model do
  it_behaves_like 'a soft deletable model'

  describe '#gravatar_image' do
    context 'with a email address' do
      before(:each) { subject.email = 'bemo56@hotmail.com' }
      context 'with no arguments' do
        it 'returns a 128px gravatar image url' do
          expected = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
          expect(subject.gravatar_image).to eq(expected)
        end
      end
      %w(16 32 64 128).each do |size|
        context "with a size argument of #{size}" do
          it "returns a #{size}px gravatar image url" do
            expected = "http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=#{size}"
            expect(subject.gravatar_image(size)).to eq(expected)
          end
        end
      end
    end
    context 'with no email address' do
      it 'returns nil' do
        expect(subject.gravatar_image).to be_nil
      end
    end
  end

  describe 'Accounts' do
    it { is_expected.to have_many(:accounts).dependent(:destroy) }

    describe '#primary_account' do
      it 'returns the first account' do
        first_account = build_stubbed(:developer_account)
        allow(subject).to receive(:accounts).and_return([
          first_account,
          build_stubbed(:developer_account)
        ])
        expect(subject.primary_account).to be(first_account)
      end
    end

    describe '#provider_account?' do
      subject { create(:user) }
      context 'with no Account' do
        Account::PROVIDERS.each do |provider|
          it "returns false for #{provider}" do
            subject.provider_account?(provider)
          end
        end
      end
      Account::PROVIDERS.each do |provider|
        context "with a #{provider} account" do
          let!(:account) { create :"#{provider}_account", user: subject }
          it "returns true for #{provider}" do
            expect(subject.provider_account? provider).to be(true)
          end
          Account::PROVIDERS.reject { |p| p == provider }.each do |p|
            it "returns false for #{p}" do
              expect(subject.provider_account? p).to be(false)
            end
          end
        end
      end
    end

    describe '#profile_picture' do
      context 'with a primary account' do
        let(:account) { build_stubbed(:developer_account) }
        before(:each) do
          # Stub the primary_account method
          allow(subject).to receive(:primary_account).and_return(account)
        end
        context 'with a profile_picture' do
          let(:account_image) { 'http://graph.facebook.com/1234567/picture?type=square' }
          before(:each) { allow(account).to receive(:profile_picture).and_return(account_image) }

          it 'returns the profile_picture from the primary account ' do
            expect(subject.profile_picture).to be(account_image)
          end
        end
        context 'without a profile picture' do
          before(:each) { allow(account).to receive(:profile_picture).and_return(nil) }

          it 'reverts back to the gravatar image' do
            gravatar_image = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
            allow(subject).to receive(:gravatar_image).and_return(gravatar_image)

            expect(subject.profile_picture).to eq(gravatar_image)
          end
        end
      end
      context 'with no accounts' do
        it 'returns the gravatar image for the user' do
          gravatar_image = 'http://gravatar.com/avatar/63095bd9974641871e51b92ef72b20a8.png?s=128'
          allow(subject).to receive(:gravatar_image).and_return(gravatar_image)

          expect(subject.profile_picture).to eq(gravatar_image)
        end
      end
    end
  end

  describe 'DeviseOverrides' do
    describe '#no_login_password?' do
      let(:instance) { described_class.new }
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

    describe '#password_required?' do
      let(:instance) { described_class.new }
      subject { instance.password_required? }

      it 'returns true when password is set' do
        instance.password = Faker::Lorem.word
        is_expected.to be(true)
      end
      it 'returns true when password_confirmation is set' do
        instance.password_confirmation = Faker::Lorem.word
        is_expected.to be(true)
      end
      context 'with a new user' do
        context 'with a new session account' do
          before(:each) do
            allow(instance).to receive(:new_session_accounts).and_return([double(:account)])
          end
          it { is_expected.to be(false) }
        end
        context 'with no new session accounts' do
          before(:each) do
            allow(instance).to receive(:new_session_accounts).and_return([])
          end
          it { is_expected.to be(true) }
        end
      end
      context 'with a persisted user' do
        let(:instance) { create(:user).tap(&:reload) }

        context 'with a new session account' do
          before(:each) do
            allow(instance).to receive(:new_session_accounts).and_return([double(:account)])
          end
          it { is_expected.to be(true) }
        end
      end
    end

    describe '#update_with_password' do
      let(:instance) { described_class.new }
      let(:attributes) { { password: 'test' } }
      subject { instance.update_with_password(attributes) }

      it 'should call update_attributes with a valid password' do
        expect(instance).to receive(:valid_password?).with(nil).and_return(true)
        expect(instance).to receive(:update_attributes)
        subject
      end
      it 'should call valid_password with allow_empty_password as true then return it to false' do
        expect(instance).to receive(:valid_password?) do
          expect(instance.send(:allow_empty_password?)).to be(true)
        end
        expect(instance).to receive(:update_attributes)
        subject
        expect(instance.send(:allow_empty_password?)).to be(false)
      end
    end

    describe '#valid_password?' do
      subject { instance.valid_password?(password) }

      context 'when the password is nil and the encrypted password is blank' do
        let(:password) { nil }
        let(:instance) { described_class.new }

        it 'should return the result from allow_empty_password?' do
          result = double('result')
          allow(instance).to receive(:allow_empty_password?).and_return(result)
          expect(subject).to eq result
        end
      end
    end
  end

  describe 'DeviseValidations' do
    describe 'email validation' do
      context 'when email is required' do
        before(:each) { allow(subject).to receive(:email_required?).and_return(true) }

        it { should validate_presence_of :email }
      end

      context 'when email has changed' do
        before(:each) { allow(subject).to receive(:email_changed?).and_return(true) }

        it { should validate_uniqueness_of :email }

        it 'should allow valid emails' do
          %w(
            a.b.c@example.com
            test_mail@gmail.com
            any@any.net
            email@test.br
            123@mail.test
            1☃3@mail.test
          ).each do |valid_email|
            should allow_value(valid_email).for(:email)
          end
        end
        it 'should not allow invalid emails' do
          %w{
            invalid_email_format
            123
            $$$
            ()
            ☃
            bla@bla.
          }.each_with_index do |invalid_email|
            should_not allow_value(invalid_email).for(:email)
          end
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

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_acceptance_of(:terms_and_conditions) }

    it 'should validate the uniqueness of email' do
      create :user
      is_expected.to validate_uniqueness_of(:email)
    end

    context 'with a existing soft deleted user' do
      let!(:user) { create(:user, :soft_deleted) }
      # Ensure validate_uniqueness_of compares against soft deleted model
      before(:each) { expect(described_class).to receive(:first).and_return(user) }

      it { is_expected.to validate_uniqueness_of(:email) }
    end
  end

  describe 'Versioning', :paper_trail do
    context 'with create event' do
      it 'creates a create version' do
        user = build :user
        with_versioning do
          expect do
            user.save!
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('create')
      end
      it 'should assign itself the item_owner' do
        user = build(:user)
        with_versioning do
          user.save!
        end
        expect(user.versions.first.item_owner).to eq(user)
      end
    end

    context 'with destroy event' do
      it 'creates a destroy version' do
        user = create :user
        with_versioning do
          expect do
            user.destroy
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('destroy')
      end
    end

    context 'with restore event' do
      it 'creates a restore version' do
        user = create :user, :soft_deleted
        with_versioning do
          expect do
            user.restore
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('restore')
      end
    end

    context 'with update event' do
      it 'creates a update version when email is changed' do
        user = create :user
        with_versioning do
          expect do
            user.update_attribute :email, Faker::Internet.email
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('update')
      end
      it 'creates a update version when name is changed' do
        user = create :user
        with_versioning do
          expect do
            user.update_attribute :name, Faker::Name.name
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('update')
      end
      it 'ignores sensitive user data' do
        user = create :user
        with_versioning do
          expect do
            user.update_attributes(
              password: 'new_password',
              password_confirmation: 'new_password'
            )
          end.to_not change(PaperTrail::Version, :count)
        end
      end
      it 'ignores devise managed properties' do
        user = create :user
        with_versioning do
          expect do
            user.update_attributes(
              reset_password_token: Faker::Code.rut,
              reset_password_sent_at: DateTime.now,
              remember_created_at: DateTime.now,
              sign_in_count: 22,
              last_sign_in_at: DateTime.now,
              last_sign_in_ip: Faker::Internet.ip_v4_address
            )
          end.to_not change(PaperTrail::Version, :count)
        end
      end
    end
  end

  describe 'Factories' do
    it 'creates a User with basic details' do
      user = create(:user)
      expect(user.name).not_to be_blank
      expect(user.email).not_to be_blank
      expect(user.encrypted_password).not_to be_nil
    end
    describe 'role traits' do
      it 'creates a admin user' do
        user = create(:user, :admin)
        expect(user).to have_role(:admin)
      end
      it 'creates a banned user' do
        user = create(:user, :banned)
        expect(user).to have_role(:banned)
      end
      it 'creates a user with no login password and a account' do
        user = create(:user, :no_login_password)
        expect(user.no_login_password?).to be(true)
        expect(user.encrypted_password).to be_blank
        expect(user.accounts.size).to be(1)
      end
    end
  end
end
