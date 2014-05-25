module Users
  class AccountsController < ::ApplicationController
    before_filter :authenticate_user!

    # Setup responders
    self.responder = UsersResponder
    respond_to :html

    # DELETE /users/accounts/1 [xhr]
    def destroy
      @account = current_user.accounts.find_by_id(params[:id])
      # Ensure User is not prevented from destroying Account (banned)
      authorize! :destroy, @account || Account

      if @account.try(:destroy)
        # FIXME: Responder is not setting flash in request specs
        flash[:notice] = t('flash.users.accounts.destroy.notice', interpolation_options)
      else
        # Display warning as account is not linked to profile
        flash[:warning] = t('flash.users.accounts.destroy.warning')
      end
      respond_with(@account, flash: @account.present?)
    end

    # POST /users/accounts/sort [xhr]
    def sort
      # Ensure User is not prevented from updating Account (banned)
      authorize! :update, Account

      # Only sort updatable Account belonging to User
      @accounts = current_user.accounts.accessible_by(current_ability, :update)
      params[:account_ids].each_with_index do |account_id, index|
        @accounts.where(id: account_id).update_all(position: index + 1)
      end
      head :ok
    end

    private

    # Set values for flash responder
    def interpolation_options
      { provider_name: @account.try(:provider_name) }
    end
  end
end
