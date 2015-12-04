class UsersController < ApplicationController
  before_action :set_user,       only: [:show, :edit, :update, :destroy, :following, :followers]
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @tweet = current_user.tweets.build if signed_in?
    @feed_items = @user.tweets.paginate(page: params[:page])
  end

  def following
    @title = "Following"
    @users = @user.followed_users.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by!(slug: params[:id])
    end

    def correct_user
      authenticate_user! unless current_user?(@user)
    end

end
