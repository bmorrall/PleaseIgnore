class Users::RegistrationsController < Devise::RegistrationsController
  helper_method :display_accounts?
  helper_method :display_profile?
  helper_method :display_password_change?

  def update
    @user = User.find(current_user.id)
    account_update_params = devise_parameter_sanitizer.sanitize(:account_update)

    successfully_updated = if needs_password_param?(@user, account_update_params)
      success_message = :updated_password
      @user.update_with_password account_update_params
    else
      success_message = :updated
      account_update_params.delete(:current_password)
      @user.update_without_password account_update_params
    end

    if successfully_updated
      set_flash_message :notice, success_message
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render :edit
    end
  end

  protected

  # Redirect Users back to the profile page after updates
  def after_update_path_for(resource)
    edit_user_registration_path
  end

  # Only display password on #show or if update profile fails
  def display_profile?
    params[:user].nil? || !params[:user].has_key?(:password)
  end

  # Only display password on #show or if change password fails
  def display_password_change?
    params[:user].nil? || params[:user].has_key?(:password)
  end

  # Only display accounts on #show
  def display_accounts?
    params[:user].nil?
  end

  private

  # Allow uses to update account without current_password
  def needs_password_param?(user, params)
    params.has_key? :password
  end

end
