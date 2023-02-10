class VideosController < ApplicationController

  def show
    @video = Video.find_by(id: params[:id])
    render json: @video
  end

  def create
    @video = @current_user.videos.new(video_params)
    @video.user_id = 1
    if @video.save
      json_success('Video uploaded successfully', @video)
    else
      json_bad_request(@video.errors.full_messages.join(', '))
    end
  end

  private

  def video_params
    params.permit(:file)
  end
end
