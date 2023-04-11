class VideoProcessWorker
  include Sidekiq::Worker

  def perform(file_path, user_id, uploaded_file=nil, video_name)
    user = User.find user_id
    if Rails.env.production?
      file = URI.open(file_path)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(file_path),
        filename: "original_filename",
        type: "content_type"
      )
    end
    video = user.videos.create!(file: file, title: video_name)
    VideoTranscriptWorker.perform_async(video.id, 'video')
  end
end
