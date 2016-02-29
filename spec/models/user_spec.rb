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
