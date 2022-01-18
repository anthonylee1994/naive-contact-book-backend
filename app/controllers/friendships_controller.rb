class FriendshipsController < ApplicationController
  before_action :set_friendship, only: %i[show update destroy]

  # GET /friendships
  def index
    @friendships = current_user.friendships

    q = {}
    q[:tags_value_cont] = params[:tag] if params[:tag].present?
    q[:target_name_cont] = params[:name] if params[:name].present?

    @friendships = @friendships.ransack(q).result if q.present?

    render json: @friendships.includes(:tags, target: [user_contacts: [:contact], avatar_attachment: :blob]),
           include: '*.*.*.*'
  end

  # GET /friendships/1
  def show
    render json: @friendship, include: '*.*.*.*'
  end

  # POST /friendships
  def create
    @friendship = current_user.friendships.new(friendship_create_params)

    if @friendship.save
      render json: @friendship, status: :created, include: '*.*.*.*'
    else
      render json: @friendship.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /friendships/1
  def update
    if @friendship.update(friendship_update_params)
      render json: @friendship, include: '*.*.*.*'
    else
      render json: @friendship.errors, status: :unprocessable_entity
    end
  end

  # DELETE /friendships/1
  def destroy
    @friendship.destroy
  end

  private

  def set_friendship
    @friendship = current_user.friendships.find(params[:id])
  end

  def friendship_create_params
    params.permit(:id, :target_id, :_otp_code, tags_attributes: %i[id value _destroy])
  end

  def friendship_update_params
    params.permit(:id, tags_attributes: %i[id value _destroy])
  end
end
