# Classes for Managing the Current User Session
module Users
  # Users Accounts Controller
  # Allows users to Delete and Sort connected OmniAuth accounts
  class AccountsController < ::ApplicationController
    # CanCanCan Authorization
    before_action :authenticate_user!
    load_resource through: :current_user, only: [:sort]
    before_action :safe_load_account_from_current_user, except: [:sort]
    authorize_resource

    # Setup responders
    self.responder = UsersResponder
    respond_to :html

    # DELETE /users/accounts/1 [xhr]
    def destroy
      if @account.try(:destroy)
        # FIXME: Responder is not setting flash in request specs
        flash[:notice] = t('flash.users.accounts.destroy.notice', interpolation_options)
      else
        # Display warning as account is not linked to profile
        flash[:warning] = t('flash.users.accounts.destroy.warning')
      end
      respond_with(@account, flash: false)
    end

    # POST /users/accounts/sort [xhr]
    def sort
      params[:account_ids].each_with_index do |account_id, index|
        @accounts.where(id: account_id).update_all(position: index + 1)
      end
      head :ok
    end

    protected

    # Loads the current users account without raising a ActiveRecord::RecordNotFound
    def safe_load_account_from_current_user
      @account = current_user.accounts.find_by_id(params[:id])
    end

    private

    # Set values for flash responder
    def interpolation_options
      { provider_name: @account.try(:provider_name) }
    end
  end
end
