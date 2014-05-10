require 'responders/user_profile_resource_responder'

class Users::AccountsController < ::ApplicationController
  before_filter :authenticate_user!
  responders :flash, :user_profile_resource

  def destroy
    @account = current_user.accounts.find_by_id(params[:id])
    if @account
      @account.destroy
      # FIXME: Responder is not setting flash in request specs
      flash[:notice] = t('flash.users.accounts.destroy.notice', interpolation_options)
    else
      # Display warning as account is not linked to profile
      flash[:warning] = t('flash.users.accounts.destroy.warning')
    end
    respond_with(@account, flash: @account.present?)
  end

  def sort
    @accounts = current_user.accounts
    params[:account_ids].each_with_index do |account_id, index|
      @accounts.where(id: account_id).update_all(position: index+1)
    end
    head :ok
  end

  private

  # Set values for flash responder
  def interpolation_options
    { provider_name: @account.try(:provider_name) }
  end

end
