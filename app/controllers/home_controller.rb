class HomeController < ApplicationController
  def index
    render json: { message: 'Naive Contact Book API' }
  end
end
