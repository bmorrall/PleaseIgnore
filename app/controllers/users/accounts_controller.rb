class Users::AccountsController < ::ApplicationController
  before_filter :authenticate_user!

  def destroy
    account = current_user.accounts.find_by_id(params[:id])
    if account
      provider_name = account.provider_name
      account.destroy
      redirect_to edit_user_registration_path, :notice => "Successfully unlinked your #{provider_name} account"
    else
      redirect_to edit_user_registration_path, :alert => "Your #{provider_name} account has already been removed"
    end
  end

end
