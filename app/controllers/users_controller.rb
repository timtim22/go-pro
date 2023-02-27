class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
  before_action :set_user, only: [:show, :destroy]

  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: { message: @user.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def update_user
    if @current_user.update(user_params)
      json_success('User successfully updated')
    else
      json_bad_request('Something went wrong')
    end
  end

  def destroy
    @user.destroy
  end

  private

  def user_params
    params.permit(:name, :business_name, :industry, :email, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
