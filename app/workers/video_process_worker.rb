class VideoProcessWorker
  include Sidekiq::Worker

  def perform(file_path, user_id, uploaded_file=nil)
    user = User.find user_id
    if Rails.env.production?
      file = URI.open(file_path)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(file_path),
        filename: uploaded_file["original_filename"],
        type: uploaded_file["content_type"]
      )
    end
    video = user.videos.create!(file: file)
    VideoTranscriptWorker.perform_async(video.id)
  end
end
