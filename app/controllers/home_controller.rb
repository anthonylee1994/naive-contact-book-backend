class HomeController < ApplicationController
  skip_before_action :authorize_request, only: :index

  def index
    render json: { message: 'Naive Contact Book API' }
  end
end
