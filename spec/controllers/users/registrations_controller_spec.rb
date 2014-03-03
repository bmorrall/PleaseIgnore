require 'spec_helper'

describe Users::RegistrationsController do

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

  let(:valid_profile_attributes) do
    FactoryGirl.attributes_for(:user).keep_if { |attribute| attribute !~ /password/ }
  end
  let(:invalid_profile_attributes) do
    { name: nil, email: nil }
  end

  describe 'GET edit' do
    context 'with a logged in user' do
      login_user
      context 'with a valid request' do
        before(:each) do
          get :edit
        end
        it 'displays all forms' do
          controller.send(:display_password_change?).should be_true
          controller.send(:display_accounts?).should be_true
          controller.send(:display_profile?).should be_true
        end
      end
    end
  end

  describe 'POST update' do
    context 'with a logged in user' do
      login_user

      context 'with a valid profile update request' do
        before(:each) do
          post :update, user: valid_profile_attributes
        end
        it { response.should redirect_to edit_user_registration_path }
        it { should set_the_flash[:notice].to('You updated your profile successfully.') }
        it 'should update the User account' do
          @logged_in_user.reload
          valid_profile_attributes.each do |key, value|
            @logged_in_user[key].should eq(value)
          end
        end
      end
      context 'with a invalid profile update request' do
        before(:each) do
          post :update, user: invalid_profile_attributes
        end
        it { should render_template(:edit) }
        it { should render_with_layout(:application) }
        it { should_not set_the_flash }
        it 'should only display the profile form' do
          controller.send(:display_profile?).should be_true
          controller.send(:display_accounts?).should be_false
          controller.send(:display_password_change?).should be_false
        end
      end


      # Password Change

      context 'with a valid password change request' do
        before(:each) do
          post :update, user: valid_password_change_attributes
        end
        it { response.should redirect_to edit_user_registration_path }
        it { should set_the_flash[:notice].to('You updated your password successfully.') }
        it 'should update the User password' do
          @logged_in_user.reload
          @logged_in_user.should be_valid_password('newpassword')
        end
      end
      context 'with a invalid password change request' do
        before(:each) do
          post :update, user: invalid_password_change_attributes
        end
        it { should render_template(:edit) }
        it { should render_with_layout(:application) }
        it { should_not set_the_flash }
        it 'should only display the password form' do
          controller.send(:display_password_change?).should be_true
          controller.send(:display_accounts?).should be_false
          controller.send(:display_profile?).should be_false
        end
        it 'should not update the User password' do
          @logged_in_user.reload
          @logged_in_user.should be_valid_password('changeme')
        end
      end
    end
  end

end