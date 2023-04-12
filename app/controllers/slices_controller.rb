class SlicesController < ApplicationController

  def all
    @slice_videos = @current_user.slice_videos.reverse
    total_count = @slice_videos.count
    data = map_all_videos(@slice_videos)
    videos = Kaminari.paginate_array(data[:videos])
    json_success('All videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  end

  def show
    @slice_video = SliceVideo.find_by(id: params[:id])
    if @slice_video.present?
      json_success('Successfully fetched video', @slice_video)
    else
      json_bad_request('Video does not exist')
    end
  end

  def recent
    @slice_videos = @current_user.slice_videos.recent.reverse
    data = map_recent_videos(@slice_videos)
    videos = Kaminari.paginate_array(data[:videos])
    json_success('All recent videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  end

  def transcript
    slice_video = SliceVideo.find_by(id: params[:slice_video_id])
    return json_bad_request('Video does not exist') if slice_video.nil?

    transcript = slice_video&.transcript&.transcript.sort_by { |word| word["videoTime"] }
    return json_bad_request('Please wait, generating a transcript may take a few seconds to minutes depending on the video length. Click the refresh icon to check for the transcript.') if transcript.nil?

    json_success('Video Transcript', transcript)
  end

  def destroy
    @slice_video = SliceVideo.find_by(id: params[:id])
    return json_bad_request('Video does not exist') if @slice_video.nil?

    if @slice_video.destroy
      json_success('Video deleted successfully')
    else
      json_bad_request('something went wrong')
    end
  end

  def cut
    @video = Video.find_by(id: params[:video_id])
    return json_bad_request('Video does not exist') if @video.nil?

    start_time = params[:start_time]
    end_time = params[:end_time]
    return json_bad_request('start_time and end_time are required fields') if start_time.nil? && end_time.nil?

    return json_bad_request('start_time cannot be greater than end_time') if invalid_start_time_check(start_time, end_time)

    return json_bad_request('end_time cannot be greater than the video duration') if max_duration_check(end_time, @video.duration)

    VideoTrimWorker.perform_async(@video.id, start_time, end_time, @current_user.id)
    json_success("Video slice is currently being processed. Once completed, You will find it in 'My Slices > Recent' section.")
  end

  private

  def max_duration_check(end_time, duration)
    hours, minutes, seconds = end_time.split(':').map(&:to_i)
    total_seconds = (hours * 3600) + (minutes * 60) + seconds
    time_in_decimal = total_seconds.to_f.round(6)

    time_in_decimal > duration
  end

  def invalid_start_time_check(start_time, end_time)
    start_seconds = Time.parse(start_time).seconds_since_midnight
    end_seconds = Time.parse(end_time).seconds_since_midnight

    start_seconds > end_seconds
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
