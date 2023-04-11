class VideoCreateWorker
  include Sidekiq::Worker

  def perform(file_path, user_id, video_name)
    user = User.find user_id
    temp_file = File.open(file_path, 'r')
    temp_file_name = File.basename(file_path)
    new_tempfile_path = Rails.root.join('tmp', "#{Time.now.to_i}_#{temp_file_name}")
    FileUtils.mkdir_p(File.dirname(new_tempfile_path))
    FileUtils.touch(new_tempfile_path)
    FileUtils.cp(file_path, new_tempfile_path)

    if Rails.env.production?
      file = upload_file_to_cloud_storage(new_tempfile_path)
    else
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(new_tempfile_path),
        filename: "original_filename",
        type: "content_type"
      )
    end

    video = user.videos.create!(file: file, title: video_name)
    VideoTranscriptWorker.perform_async(video.id, 'video')
  end

  private

  def get_video_name(file)
    words = file.original_filename.split("_").map(&:capitalize).join(" ").split(".").first
    split_words = words.split
    if split_words.length > 3
      split_words[0..2].join(" ") + " ..."
    else
      words
    end
  end
end
