class UsersController < ApplicationController
  skip_before_action :authorize_request, only: %i[sign_up]

  # POST /sign_up
  def sign_up
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST /sign_in
  def sign_in
    render json: current_user
  end

  # GET /me
  def show
    render json: current_user
  end

  # # PATCH/PUT /users/1
  def update
    if current_user.update(user_params)
      head :no_content
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    current_user.destroy
  end

  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.permit(:name)
  end
end
