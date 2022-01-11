class ApplicationController < ActionController::API
  include Authorization
  include StorageUrl

  before_action do
    return unless params

    # hacky way to solve the problem of RSWAG only recognize multipart/form-data params[:data] in test env
    self.params = Rails.env.test? ? (params[:data] || params) : params
  end
end
