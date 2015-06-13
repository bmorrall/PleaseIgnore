class Users::AuthenticationTokensController < ApplicationController
  layout 'dashboard_backend'

  before_filter :authenticate_user!
  load_and_authorize_resource :authentication_token, through: :current_user

  # GET /users/authentication_tokens
  def index
    @authentication_tokens = current_user.authentication_tokens
    @authentication_tokens = @authentication_tokens.order(:created_at)
  end

  # DELETE /users/authentication_tokens/1
  def destroy
    @authentication_token.destroy
    respond_to do |format|
      format.html { redirect_to users_authentication_tokens_url, notice: 'Authentication token was successfully destroyed.' }
    end
  end
end
