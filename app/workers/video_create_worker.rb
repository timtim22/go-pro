class VideoCreateWorker
  include Sidekiq::Worker

  def perform(file_path, user_id, video_name)
    user = User.find user_id

    if Rails.env.production?
      temp_file         = File.open(file_path, 'r')
      cloud_storage_url = upload_file_to_cloud_storage(temp_file)
      temp_file.close
      file              = URI.open(cloud_storage_url)
    else
      temp_file = File.open(file_path, 'r')
      temp_file_name = File.basename(file_path)
      new_tempfile_path = Rails.root.join('tmp', "#{Time.now.to_i}_#{temp_file_name}")
      FileUtils.mkdir_p(File.dirname(new_tempfile_path))
      FileUtils.touch(new_tempfile_path)
      FileUtils.cp(temp_file, new_tempfile_path)

      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(new_tempfile_path),
        filename: "original_filename",
        type: "content_type"
      )
    end

    video = user.videos.create!(file: file, title: video_name)
    VideoTranscriptWorker.perform_async(video.id, 'video')
  end
end
