class VideoProcessWorker
  include Sidekiq::Worker

  def perform(tempfile, uploaded_file, user_id)
    user = User.find user_id
    tempfile = File.new(tempfile)

    file = ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: uploaded_file["original_filename"],
      type: uploaded_file["content_type"]
    )

    video = user.videos.create!(file: file)
    VideoTranscriptWorker.perform_async(video.id)
  end
end
