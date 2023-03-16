class SlicesController < ApplicationController

  # def all
  #   @videos = @current_user.videos.joins(:transcript).reverse
  #   total_count = @videos.count
  #   data = map_all_videos(@videos)
  #   videos = Kaminari.paginate_array(data[:videos])
  #   json_success('All videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  # end

  # def show
  #   @video = Video.find_by(id: params[:id])
  #   if @video.present?
  #     json_success('Successfully fetched video', @video)
  #   else
  #     json_bad_request('Video does not exist')
  #   end
  # end

  # def recent
  #   @videos = @current_user.videos.joins(:transcript).recent.reverse
  #   data = map_recent_videos(@videos)
  #   videos = Kaminari.paginate_array(data[:videos])
  #   json_success('All recent videos', { total_count: data[:total_count], videos: videos.page(params[:page]).per(10) })
  # end

  # def create
  #   @video = @current_user.videos.new(video_params)
  #   file = params[:file]
  #   VideoCreateService.new(file, @current_user).call
  #   json_success("Video is being uploaded. Once completed, You will find it in 'My Library > Recent' section.")
  # end

  # def search_keyword
  #   keyword = params[:keyword]
  #   return json_bad_request('Please input atleast 4 character word') unless keyword.chars.count > 3

  #   video = @current_user.videos.find_by(id: params[:video_id])
  #   return json_bad_request('Video does not exist') unless video.present?

  #   return json_bad_request('Please wait, Processing video') unless video.transcript.present?

  #   video_transcript = video&.transcript&.transcript
  #   if video_transcript[keyword].present?
  #     json_success('Keyword Timestamp', video_transcript[keyword])
  #   else
  #     json_bad_request('Keyword does not exist')
  #   end
  # end

  # def transcript
  #   video = Video.find_by(id: params[:video_id])
  #   return json_bad_request('Video does not exist') if video.nil?

  #   transcript = video&.transcript&.transcript
  #   return json_bad_request('Error generating transcript') if transcript.nil?

  #   json_success('Video Transcript', transcript)
  # end

  # def destroy
  #   @video = Video.find_by(id: params[:id])
  #   return json_bad_request('Video does not exist') if @video.nil?

  #   if @video.destroy
  #     json_success('Video deleted successfully')
  #   else
  #     json_bad_request('something went wrong')
  #   end
  # end

  def cut
    @video = Video.find_by(id: params[:video_id])
    return json_bad_request('Video does not exist') if @video.nil?

    json_success("Video slice is currently being processed. Once completed, You will find it in 'My Slices > Recent' section.")
  end

  private

  # def video_params
  #   params.permit(:file)
  # end

  # def map_all_videos(videos)
  #   {
  #     total_count: videos.count,
  #     videos: videos.map do |video|
  #       {
  #         id: video.id,
  #         file: {
  #           url: video.file.url
  #         },
  #         date: video.created_at.strftime("%d-%m-%Y %H:%M:%S"),
  #         name: get_name(video)
  #       }
  #     end
  #   }
  # end

  # def map_recent_videos(videos)
  #   {
  #     total_count: videos.count,
  #     videos: videos.map do |video|
  #       {
  #         id: video.id,
  #         file: {
  #           url: video.file.url
  #         },
  #         date: video.relative_time_since_creation,
  #         name: get_name(video)
  #       }
  #     end
  #   }
  # end

  # def get_name(video)
  #   words = video.file.identifier.split("_").map(&:capitalize).join(" ").split(".").first
  #   split_words = words.split
  #   if split_words.length > 3
  #     split_words[0..2].join(" ") + " ..."
  #   else
  #     words
  #   end
  # end
end
