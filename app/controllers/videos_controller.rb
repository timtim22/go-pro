class VideosController < ApplicationController


  def all
    @videos = @current_user.videos.reverse
    total_count = @videos.count
    data = map_all_videos(@videos)
    videos = Kaminari.paginate_array(data[:videos])
    json_success('All videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  end

  def show
    @video = Video.find_by(id: params[:id])
    if @video.present?
      json_success('Successfully fetched video', @video)
    else
      json_bad_request('Video does not exist')
    end
  end

  def recent
    @videos = @current_user.videos.recent.reverse
    data = map_recent_videos(@videos)
    videos = Kaminari.paginate_array(data[:videos])
    json_success('All recent videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
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

  def destroy
    @video = Video.find(params[:id])
    if @video.destroy
      json_success('Video deleted successfully')
    else
      json_bad_request('something went wrong')
    end
  end

  private

  def video_params
    params.permit(:file)
  end

  def map_all_videos(videos)
    {
      total_count: videos.count,
      videos: videos.map do |video|
        {
          id: video.id,
          file: {
            url: video.file.url
          },
          date: video.created_at.strftime("%d-%m-%Y %H:%M:%S")
        }
      end
    }
  end

  def map_recent_videos(videos)
    {
      total_count: videos.count,
      videos: videos.map do |video|
        {
          id: video.id,
          file: {
            url: video.file.url
          },
          date: video.relative_time_since_creation
        }
      end
    }
  end
end
