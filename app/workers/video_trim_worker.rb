class VideoTrimWorker
  include Sidekiq::Worker

  def perform(video_id, start_time, end_time, user_id)
    user = User.find_by(id: user_id)
    video = Video.find_by(id: video_id)
    if Rails.env.production?
      storage = Google::Cloud::Storage.new(
        project_id: ENV['PROJECT_ID'],
        credentials: decoded_google_credentials
      )
      bucket = storage.bucket(ENV['BUCKET_NAME'])
      bucket_file = bucket.file(video.file.path)
      current_file_path = File.join(Rails.root, "tmp", "#{SecureRandom.uuid}_#{video.id}")
      output_file_path = File.join(Rails.root, "tmp", "trimmed_#{SecureRandom.uuid}_#{video.id}.mp4")
      bucket_file.download(current_file_path)
      `ffmpeg -i #{current_file_path} -ss #{start_time} -t #{end_time} -async 1 #{output_file_path}`

      file = URI.open(output_file_path)
      slice_video = SliceVideo.create!(file: file, video: video, title: video.title, user: user)
    else
      output_path = "#{Rails.root}/tmp/trimmed_#{Time.now.to_i}_#{video.id}.mp4"
      system("ffmpeg -ss #{start_time} -to #{end_time} -i #{video.file.path} -c copy #{output_path}")
    
      file = ActionDispatch::Http::UploadedFile.new(
        tempfile: File.new(output_path),
        filename: video.title,
        type: 'mp4'
      )
      slice_video = SliceVideo.create!(file: file, video: video, title: video.title, user: user)
    end

    VideoTranscriptWorker.perform_async(slice_video.id, 'slice_video')
    if Rails.env.production?
      File.delete current_file_path
      File.delete output_file_path
    end
  end

  def decoded_google_credentials    
    Base64.decode64(ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]) if ENV["GOOGLE_APPLICATION_CREDENTIALS_BASE64"]
  end
end
