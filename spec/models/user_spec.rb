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
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_deleted_at            (deleted_at)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'rails_helper'

describe User, type: :model do
  it_behaves_like 'a soft deletable model'

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

  describe 'Associations' do
    describe '#organisations' do
      let(:instance) { create :user }
      subject { instance.organisations }

      it 'should return the organisations the user has an owner role on' do
        organisation = create(:organisation)
        instance.add_role :owner, organisation

        expect(subject).to eq [organisation]
      end
      it 'should not include organisations the user is not assigned to' do
        create(:organisation)

        expect(subject).to eq []
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
  end

  describe 'DeviseValidations' do
    describe 'email validation' do
      context 'when email is required' do
        before(:each) { allow(subject).to receive(:email_required?).and_return(true) }

        it { should validate_presence_of :email }
      end

      context 'when email has changed' do
        before(:each) { allow(subject).to receive(:email_changed?).and_return(true) }

        it { should validate_uniqueness_of(:email).case_insensitive }

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

  describe 'RoleVersioning', :paper_trail do
    context 'when adding a role to a user' do
      it 'should create a PaperTrail::Version with the user as the item owner' do
        user = create(:user)
        with_versioning do
          expect { user.add_role(:admin) }.to change(PaperTrail::Version, :count).by(1)
        end

        create_version = PaperTrail::Version.last
        expect(create_version.item_owner).to eq user
        expect(create_version.meta).to include(user_id: user.id, role: 'admin')
        expect(create_version.event).to eq 'create'
      end
    end
    context 'when removing a role from a user' do
      it 'should create a PaperTrail::Version with the user as the item owner' do
        user = create(:user)
        user.add_role(:admin)

        with_versioning do
          expect { user.remove_role(:admin) }.to change(PaperTrail::Version, :count).by(1)
        end

        create_version = PaperTrail::Version.last
        expect(create_version.item_owner).to eq user
        expect(create_version.meta).to include(user_id: user.id, role: 'admin')
        expect(create_version.event).to eq 'destroy'
      end
    end

    context 'when adding a association role to a user object' do
      it 'should create a PaperTrail::Version with the object as the item owner' do
        user = create(:user)
        organisation = create(:organisation)

        with_versioning do
          expect do
            user.add_role(:owner, organisation)
          end.to change(PaperTrail::Version, :count).by(1)
        end

        create_version = PaperTrail::Version.last
        expect(create_version.item_owner).to eq organisation
        expect(create_version.meta).to include(user_id: user.id, role: 'owner')
        expect(create_version.event).to eq 'create'
      end
    end
    context 'when removing a association role from a user object' do
      it 'should create a PaperTrail::Version with the user as the item owner' do
        user = create(:user)
        organisation = create(:organisation)
        user.add_role(:owner, organisation)

        with_versioning do
          expect do
            user.remove_role(:owner, organisation)
          end.to change(PaperTrail::Version, :count).by(1)
        end

        create_version = PaperTrail::Version.last
        expect(create_version.item_owner).to eq organisation
        expect(create_version.meta).to include(user_id: user.id, role: 'owner')
        expect(create_version.event).to eq 'destroy'
      end
    end
  end

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
      it 'creates a update version when confirmed_at is changed' do
        user = create :user
        with_versioning do
          expect do
            user.confirm
          end.to change(PaperTrail::Version, :count).by(1)
        end
        expect(user.versions.last.event).to eq('update')
        expect(user.versions.last.changeset.size).to be 1
        expect(user.versions.last.changeset).to have_key('confirmed_at')
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
      it 'creates a confirmed user' do
        user = create(:user, :confirmed)
        expect(user).to be_confirmed_at
      end
      it 'creates a user with no login password and a account' do
        user = create(:user, :no_login_password)
        expect(user.no_login_password?).to be(true)
        expect(user.encrypted_password).to be_blank
        expect(user.accounts.size).to be(1)
      end

      it 'creates a soft deleted user' do
        user = create(:user, :soft_deleted)
        expect(user).to be_deleted_at
        expect(user).to_not be_expired
      end
      it 'creates a expired user' do
        user = create(:user, :expired)
        expect(user).to be_deleted_at
        expect(user).to be_expired
      end
    end
  end
end
