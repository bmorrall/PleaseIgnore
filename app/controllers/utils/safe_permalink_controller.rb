module Utils
  # Converts a String into a safe permalink
  class SafePermalinkController < ActionController::Base
    respond_to :json

    # GET /utils/safe_permalink
    #
    # Converts a value into a safe permalink string
    #
    # @example Convert 'Briggs & Stratton' into a permalink
    #   "get :create, value: 'Briggs & Stratton' => { result: 'briggs-stratton' }"
    # @api public
    # @return void
    def create
      render json: { result: value_param.safe_permalink }
    end

    protected

    # @api private
    # @return [String] the value to be converted
    def value_param
      params[:value] || ''
    end
  end
end
