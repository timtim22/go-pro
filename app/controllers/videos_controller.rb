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
    file = params[:file]
    file_url = upload_file_to_cloud_storage(file)
    VideoProcessWorker.perform_async(file_url, @current_user.id)
    json_success("Video is being uploaded. Once completed, You will find it in 'My Library > Recent' section.")
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

  def transcript
    video = Video.find params[:video_id]
    transcript = video.transcript.transcript
    inverted_hash = transcript.invert
    new_hash = {}
    inverted_hash.each do |key, value|
      new_hash[value] = key.join.to_i
    end
    if transcript.present?
      ordered_hash = new_hash.sort_by { |key, value| value }.to_h
      json_success('Video Transcript', ordered_hash)
    else
      json_bad_request('Error generating transcript')
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

  def upload_file_to_cloud_storage(file)
    storage = Google::Cloud::Storage.new(
      project_id: ENV['PROJECT_ID'],
      credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
    )
    bucket = storage.bucket(ENV['BUCKET_NAME'])
    file_path = "uploads/#{SecureRandom.uuid}_#{file.original_filename}"
    bucket.create_file(file.path, file_path)
    bucket.file(file_path).signed_url(method: 'GET', expires: 1.hour.from_now.to_i)
  end

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
          date: video.created_at.strftime("%d-%m-%Y %H:%M:%S"),
          name: get_name(video)
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
          date: video.relative_time_since_creation,
          name: get_name(video)
        }
      end
    }
  end

  def get_name(video)
    words = video.file.identifier.split("_").map(&:capitalize).join(" ").split(".").first
    split_words = words.split
    if split_words.length > 3
      split_words[0..2].join(" ") + " ..."
    else
      words
    end
  end
end
