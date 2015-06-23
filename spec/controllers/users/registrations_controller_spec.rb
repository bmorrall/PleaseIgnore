require 'rails_helper'

describe Users::RegistrationsController, type: :controller do
  let(:valid_password_change_attributes) do
    {
      password: 'newpassword',
      password_confirmation: 'newpassword',
      current_password: 'changeme'
    }
  end
  let(:invalid_password_change_attributes) do
    {
      password: 'newpassword'
    }
  end

  let(:valid_update_attributes) do
    attributes_for(:user).keep_if { |attribute| attribute !~ /email|password/ }
  end
  let(:invalid_update_attributes) do
    { name: nil }
  end

  describe 'GET edit' do
    context 'with a logged in user' do
      login_user
      context 'with a valid request' do
        before(:each) do
          get :edit
        end
        it { is_expected.to render_template(:edit) }
        it { is_expected.to render_with_layout(:dashboard_backend) }
        it 'displays all forms' do
          expect(controller.send(:display_password_change?)).to be(true)
          expect(controller.send(:display_accounts?)).to be(true)
          expect(controller.send(:display_profile?)).to be(true)
        end
      end
    end
  end

  describe 'POST update' do
    context 'with a logged in user' do
      login_user

      context 'with a valid profile update request' do
        before(:each) do
          post :update, user: valid_update_attributes
        end
        it { expect(response).to redirect_to edit_user_registration_path }
        it { is_expected.to set_flash[:notice].to(t('devise.registrations.updated')) }
        it 'should update the User account' do
          @logged_in_user.reload
          valid_update_attributes.each do |key, value|
            expect(@logged_in_user[key]).to eq(value)
          end
        end
      end
      context 'with a invalid profile update request' do
        before(:each) do
          post :update, user: invalid_update_attributes
        end
        it { is_expected.to render_template(:edit) }
        it { is_expected.to render_with_layout(:dashboard_backend) }
        it { is_expected.not_to set_flash }
        it 'should only display the profile form' do
          expect(controller.send(:display_profile?)).to be(true)
          expect(controller.send(:display_accounts?)).to be(false)
          expect(controller.send(:display_password_change?)).to be(false)
        end
      end

      # Password Change

      context 'with a valid password change request' do
        before(:each) do
          post :update, user: valid_password_change_attributes
        end
        it { expect(response).to redirect_to edit_user_registration_path }
        it { is_expected.to set_flash[:notice].to(t('devise.registrations.updated_password')) }
        it 'should update the User password' do
          @logged_in_user.reload
          expect(@logged_in_user).to be_valid_password('newpassword')
        end
      end
      context 'with a invalid password change request' do
        before(:each) do
          post :update, user: invalid_password_change_attributes
        end
        it { is_expected.to render_template(:edit) }
        it { is_expected.to render_with_layout(:dashboard_backend) }
        it { is_expected.not_to set_flash }
        it 'should only display the password form' do
          expect(controller.send(:display_password_change?)).to be(true)
          expect(controller.send(:display_accounts?)).to be(false)
          expect(controller.send(:display_profile?)).to be(false)
        end
        it 'should not update the User password' do
          @logged_in_user.reload
          expect(@logged_in_user).to be_valid_password('changeme')
        end
      end
    end
  end

  describe 'DELETE destroy' do
    context 'with a logged in user' do
      login_user

      context 'with no delete permission' do
        it 'should raise a CanCan::AccessDenied exception' do
          expect { delete :destroy }.to raise_error(CanCan::AccessDenied)
        end
      end
    end
  end
end
