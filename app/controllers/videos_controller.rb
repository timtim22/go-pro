class VideosController < ApplicationController

  def show
    @video = Video.find_by(id: params[:id])
    render json: @video
  end

  def create
    @video = @current_user.videos.new(video_params)
    @video.user_id = 1
    if @video.save
      render json: {message: 'Video uploaded successfully'}, status: :created
    else
      render json: {message: @video.errors.full_messages.join(', ')}, status: :bad_request
    end
  end

  private

  def video_params
    params.permit(:file)
  end
end
