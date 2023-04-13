class VideosController < ApplicationController
  include CloudStorageHelper

  def all
    @videos = @current_user.videos.joins(:transcript).reverse
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
    @videos = @current_user.videos.joins(:transcript).recent.reverse
    data = map_recent_videos(@videos)
    videos = Kaminari.paginate_array(data[:videos])
    json_success('All recent videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  end

  def create
    @video = @current_user.videos.new(video_params)
    file = params[:file]
    return json_bad_request('File is missing') if file.nil?

    if Rails.env.production?
      temp_file = upload_file_to_cloud_storage(file)
    else
      temp_file = Tempfile.new(["uploaded_video", ".mp4"])
      temp_file.binmode
      temp_file.write(file.read)
      temp_file.rewind
      file_path = temp_file.path
    end
    VideoCreateWorker.perform_async(temp_file, @current_user.id, get_video_name(file))
    json_success("Video is being uploaded. Once completed, You will find it in 'My Library > Recent' section.")
  end

  def transcript
    video = Video.find_by(id: params[:video_id])
    return json_bad_request('Video does not exist') if video.nil?

    transcript = video&.transcript&.transcript.sort_by { |word| word["videoTime"] }
    return json_bad_request('Error generating transcript') if transcript.nil?

    json_success('Video Transcript', transcript)
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

  def get_video_name(file)
    words = file.original_filename.split("_").map(&:capitalize).join(" ").split(".").first
    split_words = words.split
    if split_words.length > 4
      split_words[0..3].join(" ") + " ..."
    else
      words
    end
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
          name: video.title
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
          name: video.title
        }
      end
    }
  end
end
