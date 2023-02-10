class VideosController < ApplicationController

  def show
    @video = Video.find_by(id: params[:id])
    send_file @video.file.path, type: @video.file.content_type, disposition: 'inline'
  end

  def create
    @video = @current_user.videos.new(video_params)
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
