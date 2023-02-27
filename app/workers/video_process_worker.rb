class VideoProcessWorker
  include Sidekiq::Worker

  def perform(tempfile, uploaded_file, user_id)
    user = User.find user_id
    tempfile = File.new(tempfile)
    if Rails.env.production?
      storage = Google::Cloud::Storage.new(
        project_id: ENV["PROJECT_ID"],
        credentials: ENV['GOOGLE_APPLICATION_CREDENTIALS']
      )

      bucket_name = ENV['BUCKET_NAME']
      bucket = storage.bucket(bucket_name)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: uploaded_file["original_filename"],
        type: uploaded_file["content_type"]
      )
    end

    video = user.videos.create!(file: file)
  end
end
