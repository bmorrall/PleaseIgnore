module Utils
  # Converts a String into a safe permalink
  class SafePermalinkController < ApplicationController
    respond_to :json

    # GET /utils/safe_permalink
    def create
      render json: { result: value_param.safe_permalink }
    end

    protected

    def value_param
      params[:value] || ''
    end
  end
end
