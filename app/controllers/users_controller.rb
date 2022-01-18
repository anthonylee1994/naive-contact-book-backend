class UsersController < ApplicationController
  skip_before_action :authorize_request, only: %i[sign_up]

  # POST /sign_up
  def sign_up
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, show_secret: true, include: '*.*.*'
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # POST /sign_in
  def sign_in
    render json: current_user, show_secret: true, include: '*.*.*'
  end

  # GET /me
  def show
    render json: current_user, show_secret: true, include: '*.*.*'
  end

  # # PATCH/PUT /users/1
  def update
    if current_user.update(user_params)
      render json: current_user, show_secret: true, include: '*.*.*'
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
    params.permit(
      :name,
      _avatar_attributes: %i[purge file],
      user_contacts_attributes: [
        :id,
        :display_order,
        :contact_type,
        :_destroy,
        {
          contact_attributes: %i[
            phone_number
            username
            address
          ]
        }
      ]
    )
  end
end
