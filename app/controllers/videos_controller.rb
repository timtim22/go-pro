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
    VideoTranscriptWorker.perform_async(@video.id)
  end

  def search_keyword
    keyword = params[:keyword]
    if keyword.chars.count > 3
      video = @current_user.videos.find_by(id: params[:video_id])
      if video.present?
        if video.transcript.present?
          video_transcript = video&.transcript&.transcript
          if video_transcript[keyword].present?
            json_success('Keyword Timestamp', video_transcript[keyword])
          else
            json_bad_request('Keyword does not exist')
          end
        else
          json_bad_request('Please wait, Processing video')
        end
      else
        json_bad_request('Video does not exist')
      end
    else
      json_bad_request('Please input atleast 4 character word')
    end
  end

  private

  def video_params
    params.permit(:file)
  end
end
