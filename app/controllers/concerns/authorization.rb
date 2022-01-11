module Authorization
  extend ActiveSupport::Concern

  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end

  included do
    before_action :authorize_request

    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from AuthenticationError, with: :unauthorized_request
    rescue_from MissingToken, with: :four_twenty_two

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { message: e.message }, status: :not_found
    end
  end

  def current_user
    @current_user
  end

  private

  def authorize_request
    @current_user = User.find_by!(secret: request_secret)
  rescue StandardError
    raise AuthenticationError
  end

  def four_twenty_two(e)
    render json: { message: e.message }, status: :unprocessable_entity
  end

  def unauthorized_request(e)
    render json: { message: e.message }, status: :unauthorized
  end

  def request_secret
    return request.headers['Authorization'].split(' ').last if request.headers['Authorization'].present?

    raise MissingToken
  end
end
