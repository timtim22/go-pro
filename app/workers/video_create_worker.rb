class VideoCreateWorker
  include Sidekiq::Worker
  include CloudStorageHelper

  def perform(file_path, user_id, video_name)
    user = User.find user_id

    if Rails.env.production?
      temp_file = URI.open(file_path)
      original_filename = File.basename(file_path)
      file      = upload_file_to_cloud_storage(temp_file, original_filename, folder: "uploads")
      temp_file.close
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
